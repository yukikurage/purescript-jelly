module Jelly.Generator where

import Prelude

import Control.Parallel (parTraverse_)
import Control.Safely (for_, traverse_)
import Data.Array (fold, length, replicate)
import Data.Either (Either(..))
import Data.Int (floor)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Posix.Signal (Signal(..))
import Data.String as String
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
import Node.FS.Aff (mkdir', stat, writeTextFile)
import Node.FS.Perms (all, mkPerms)
import Node.FS.Stats (Stats(..))
import Node.Path (concat)
import Node.Stream (onDataString)

jellyPrefix :: String
jellyPrefix = ""

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
  rendered <- liftEffect $ render component
  mkdir' output { recursive: true, mode: mkPerms all all all }
  writeTextFile UTF8 htmlPath $ rendered

generateJS :: String -> String -> Aff Unit
generateJS output clientMain = do
  let
    cmd /\ args = bundleCommand output clientMain
  log $ jellyPrefix <> "🏃 Running \"" <> cmd <> "" <> fold (map (" " <> _) args) <> "\""
  cp <- liftEffect $ spawn cmd args defaultSpawnOptions
  waitExit cp

generateData :: String -> Aff String -> Aff String
generateData output fetchData = do
  let
    dataPath = concat [ output, "data" ]
  dt <- fetchData
  mkdir' output { recursive: true, mode: mkPerms all all all }
  writeTextFile UTF8 dataPath dt
  pure dt

replicateStr :: Int -> String -> String
replicateStr i str = fold $ replicate i str

truncate :: Int -> String -> String
truncate i str =
  if String.length str > i then String.take (i - 3) str <> "..."
  else str <> replicateStr (i - String.length str) " "

pathWidth :: Int
pathWidth = 30

printPath :: String -> String
printPath = truncate pathWidth

sizeWidth :: Int
sizeWidth = 30

printSize :: Int -> String
printSize byte =
  let
    sizeStr = case unit of
      _
        | byte < 1024 -> show byte <> " B"
        | byte < 1024 * 1024 -> show (byte / 1024) <> " KB"
        | byte < 1024 * 1024 * 1024 -> show (byte / 1024 / 1024) <> " MB"
        | otherwise -> show (byte / 1024 / 1024 / 1024) <> " GB"
  in
    truncate sizeWidth sizeStr

summary :: String -> Array String -> Aff Unit
summary root outputs = do
  Stats { size: mainJsSize } <- stat $ concat [ root, "index.js" ]
  log $ ""
  log $ "  " <> "Main Script (On first load)"
  log $ "    " <> printSize (floor mainJsSize)
  log ""
  log $ "  " <> "HTML / Data"
  log $ "    " <> truncate pathWidth "" <> " " <> truncate sizeWidth "HTML (On first load)"
    <> " "
    <> truncate
      sizeWidth
      "Data (At page transition)"
  let
    htmlAndDataSummary output = do
      Stats { size: htmlSize } <- stat $ concat [ root, output, "index.html" ]
      Stats { size: dataSize } <- stat $ concat [ root, output, "data" ]
      log $ "    "
        <> printPath output
        <> " "
        <> printSize (floor htmlSize)
        <> " "
        <> printSize (floor dataSize)
  traverse_ htmlAndDataSummary outputs
  pure unit

generate
  :: forall context page
   . Eq page
  => Config context page
  -> Aff Unit
generate { rootComponent, basePath, pageToUrl, getPages, clientMain, output, pageComponent } = do
  log ""
  log ""
  log $ jellyPrefix <> "----------------------"
  log $ jellyPrefix <> "🍮 Jelly Generator 🍮"
  log $ jellyPrefix <> "----------------------"
  log ""
  log $ jellyPrefix <> "📖  Retrieving page list..."
  log ""
  pages <- getPages
  log $ "  " <> show (length pages) <> " pages"
  log ""
  for_ pages \page -> do
    log $ "    " <> makeAbsoluteUrlPath (pageToUrl page).path
  log ""
  log $ jellyPrefix <> "🏗️  HTML / Data generating..."
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
          pageSig /\ _ <- signal page
          pure $ contextProvider { __router: { pageSig, pushPage: const $ pure unit } } component

      staticData <- generateData pageOutput getStaticData

      generateHTML pageOutput $ mockRouterProvider $ rootComponent $ component staticData
  parTraverse_ generatePageHTML pages
  log $ jellyPrefix <> "📄  HTML / Data generated"
  log ""
  log $ jellyPrefix <> "🏗️  Main script generating..."
  generateJS output clientMain
  log $ jellyPrefix <> "⚙️  Main script generated"
  log ""
  log $ jellyPrefix <> "🚩  Static pages successfully generated"
  log ""
  log $ jellyPrefix <> "📦  File Size"
  summary output $ map (\{ path } -> concat [ makeAbsoluteUrlPath path ]) $ map pageToUrl
    pages
  log ""
  log ""
