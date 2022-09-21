module Jelly.Generator where

import Prelude

import Control.Parallel (parTraverse_)
import Control.Safely (for_)
import Data.Array (fold, length)
import Data.Either (Either(..))
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Posix.Signal (Signal(..))
import Data.Traversable (traverse)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Aff (Aff, Canceler(..), error, makeAff, throwError)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Class.Console as Console
import Effect.Ref (new)
import Jelly.Data.Component (Component, runComponent)
import Jelly.Data.Config (Config)
import Jelly.Data.Emitter (emit, newEmitter)
import Jelly.Data.Hooks (makeComponent)
import Jelly.Data.Instance (toHTML)
import Jelly.Data.Signal (readSignal, signal)
import Jelly.Data.Url (makeAbsoluteUrlPath, urlToString)
import Jelly.El (contextProvider)
import Node.ChildProcess (ChildProcess, Exit(..), defaultSpawnOptions, kill, onExit, spawn, stderr, stdout)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (mkdir', writeTextFile)
import Node.FS.Perms (all, mkPerms)
import Node.Path (concat)
import Node.Stream (onDataString)

jellyPrefix :: String
jellyPrefix = "🍮 > "

render :: Component () -> Effect String
render component = do
  unmountEmitter <- newEmitter
  realInstanceRef <- new Nothing
  insts <- readSignal =<< runComponent component { context: {}, unmountEmitter, realInstanceRef }
  emit unmountEmitter
  fold <$> traverse toHTML insts

bundleCommand :: String -> String -> String /\ Array String
bundleCommand output clientMain =
  "npx" /\
    [ "spago"
    , "bundle-app"
    , "--main"
    , clientMain
    , "--to"
    , concat [ output, "index.js" ]
    , "--minify"
    ]

waitExit :: ChildProcess -> Aff Unit
waitExit cp = makeAff \callback -> do
  onExit cp \code -> callback $ case code of
    Normally 0 -> Right unit
    _ -> Left $ error $ "Command failed with code " <> show code
  pure $ Canceler \_ -> liftEffect $ kill SIGTERM cp

logStdOut :: ChildProcess -> Effect Unit
logStdOut cp = do
  let
    streamOut = stdout cp
    streamErr = stderr cp
  onDataString streamOut UTF8 \str -> log $ str
  onDataString streamErr UTF8 \str -> Console.error $ str

generateHTML :: String -> Component () -> Aff Unit
generateHTML output component = do
  let
    htmlPath = concat [ output, "index.html" ]
  log $ jellyPrefix <> "HTML Generating... " <> htmlPath
  rendered <- liftEffect $ render component
  mkdir' output { recursive: true, mode: mkPerms all all all }
  writeTextFile UTF8 htmlPath $ rendered
  log $ jellyPrefix <> "HTML Generated: " <> htmlPath

generateJS :: String -> String -> Aff Unit
generateJS output clientMain = do
  let
    jsPath = concat [ output, "index.js" ]
    cmd /\ args = bundleCommand output clientMain
  log $ jellyPrefix <> "Main Script Generating...: " <> jsPath
  log $ jellyPrefix <> "Running \"" <> cmd <> "" <> fold (map (" " <> _) args) <> "\""
  cp <- liftEffect $ spawn cmd args defaultSpawnOptions
  liftEffect $ logStdOut cp
  waitExit cp
  log $ jellyPrefix <> "Main Script Generated: " <> jsPath

generateData :: String -> Aff String -> Aff String
generateData output fetchData = do
  let
    dataPath = concat [ output, "data" ]
  log $ jellyPrefix <> "Static Data Generating...: " <> dataPath
  dt <- fetchData
  mkdir' output { recursive: true, mode: mkPerms all all all }
  writeTextFile UTF8 dataPath dt
  log $ jellyPrefix <> "Static Data Generated: " <> dataPath
  pure dt

generate
  :: forall page
   . Eq page
  => Config page
  -> Aff Unit
generate { rootComponent, basePath, pageToUrl, getPages, clientMain, output, pageComponent } = do
  log $ jellyPrefix <> "Retrieving page list..."
  pages <- getPages
  log $ jellyPrefix <> "Page list retrieved: " <> show (length pages) <> " pages"
  for_ pages \page -> do
    log $ jellyPrefix <> "- " <> urlToString basePath (pageToUrl page)
  let
    generatePageHTML page = do
      let
        { component, getStaticData } = pageComponent page
        { path, query, hash } = pageToUrl page
      when (not (Map.isEmpty query) || hash /= "") do
        log $ jellyPrefix <> "Error: Page " <> makeAbsoluteUrlPath path <>
          " has query or hash, which is not supported by Jelly Generator"
        throwError $ error "Page has query or hash"
      let
        pageOutput = concat [ output, makeAbsoluteUrlPath path ]
        mockRouterProvider component = makeComponent do
          pageSig /\ pageAtom <- signal page
          pure $ contextProvider { __router: { pageSig, pageAtom } } component

      staticData <- generateData pageOutput getStaticData

      generateHTML pageOutput $ mockRouterProvider $ rootComponent $ component staticData
  parTraverse_ generatePageHTML pages
  generateJS output clientMain
