module Jelly.Generator where

import Prelude

import Control.Parallel (parTraverse, parTraverse_)
import Data.Array (fold, zip)
import Data.Either (Either(..))
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Posix.Signal (Signal(..))
import Data.Traversable (traverse)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Aff (Aff, Canceler(..), error, makeAff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Class.Console as Console
import Effect.Ref (new)
import Jelly.Data.Component (Component, runComponent)
import Jelly.Data.Emitter (emit, newEmitter)
import Jelly.Data.Instance (toHTML)
import Jelly.Data.Signal (readSignal)
import Jelly.Util (makeAbsoluteUrlPath)
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
  realNodeRef <- new Nothing
  insts <- readSignal =<< runComponent component { context: {}, unmountEmitter, realNodeRef }
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
  log $ jellyPrefix <> "HTML Generating: " <> htmlPath
  rendered <- liftEffect $ render component
  mkdir' output { recursive: true, mode: mkPerms all all all }
  writeTextFile UTF8 htmlPath $ rendered
  log $ jellyPrefix <> "HTML Generated: " <> htmlPath

generateJS :: String -> String -> Aff Unit
generateJS output clientMain = do
  let
    jsPath = concat [ output, "index.js" ]
    cmd /\ args = bundleCommand output clientMain
  log $ jellyPrefix <> "Main Script Generating: " <> jsPath
  log $ jellyPrefix <> "Running \"" <> cmd <> "" <> fold (map (" " <> _) args) <> "\""
  cp <- liftEffect $ spawn cmd args defaultSpawnOptions
  liftEffect $ logStdOut cp
  waitExit cp
  log $ jellyPrefix <> "Main Script Generated: " <> jsPath

generateData :: String -> String -> Aff String -> Aff String
generateData output name fetchData = do
  let
    dataPath = concat [ output, name ]
  log $ jellyPrefix <> "Chunk Data Generating: " <> dataPath
  dt <- fetchData
  mkdir' output { recursive: true, mode: mkPerms all all all }
  writeTextFile UTF8 dataPath dt
  log $ jellyPrefix <> "Chunk Data Generated: " <> dataPath
  pure dt

type GeneratorSettings page chunk =
  { pageToPath :: page -> Array String
  , pages :: Array page
  , chunks :: Array chunk
  , output :: String
  , clientMain :: String
  , component :: (chunk -> Aff (Maybe String)) -> page -> Component ()
  , chunkData :: chunk -> Aff String
  }

generate
  :: forall page chunk
   . Show chunk
  => Ord chunk
  => GeneratorSettings page chunk
  -> Aff Unit
generate { pageToPath, pages, chunks, output, clientMain, component, chunkData } = do
  let
    generateChunkData chunk = do
      let
        chunkOutput = concat [ output, "data/" ]
      generateData chunkOutput (show chunk) $ chunkData chunk
  chunkDatas <- parTraverse generateChunkData chunks
  let
    chunkDataMap = Map.fromFoldable $ zip chunks chunkDatas
    generatePageHTML page = do
      let
        pageOutput = concat [ output, makeAbsoluteUrlPath (pageToPath page) ]
      generateHTML pageOutput $ component (\chunk -> pure $ Map.lookup chunk chunkDataMap) page
  parTraverse_ generatePageHTML pages
  generateJS output clientMain
