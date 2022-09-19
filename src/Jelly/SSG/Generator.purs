module Jelly.SSG.Generator where

import Prelude

import Data.Array (fold)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Posix.Signal (Signal(..))
import Data.Traversable (traverse)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Aff (Aff, Canceler(..), error, launchAff_, makeAff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Class.Console as Console
import Effect.Ref (new)
import Jelly.Data.Component (Component, runComponent)
import Jelly.Data.Emitter (newEmitter)
import Jelly.Data.Instance (toHTML)
import Jelly.Data.Signal (readSignal)
import Node.ChildProcess (ChildProcess, Exit(..), defaultSpawnOptions, kill, onExit, spawn, stderr, stdout)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (mkdir', writeTextFile)
import Node.FS.Perms (all, mkPerms)
import Node.Path (concat)
import Node.Process (exit)
import Node.Stream (onDataString)

data GeneratorSettings = GeneratorSettings
  { clientMain :: String
  , output :: String
  , component :: Component ()
  }

jellyPrefix :: String
jellyPrefix = "🍮 > "

render :: Component () -> Effect String
render component = do
  unmountEmitter <- newEmitter
  realNodeRef <- new Nothing
  insts <- readSignal =<< runComponent component { context: {}, unmountEmitter, realNodeRef }
  fold <$> traverse toHTML insts

bundleCommand :: GeneratorSettings -> String /\ Array String
bundleCommand (GeneratorSettings { clientMain, output }) =
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

generate :: GeneratorSettings -> Effect Unit
generate settings@(GeneratorSettings { output, component }) = launchAff_ do
  log $ jellyPrefix <> "Rendering HTML..."
  rendered <- liftEffect $ render component
  mkdir' output { recursive: true, mode: mkPerms all all all }
  writeTextFile UTF8 (concat [ output, "index.html" ]) $ rendered
  log $ jellyPrefix <> "Rendering Succeed and output file to " <> concat [ output, "index.html" ]

  let
    cmd /\ args = bundleCommand settings
  log $ jellyPrefix <> "Running \"" <> cmd <> "" <> fold (map (" " <> _) args) <> "\""
  cp <- liftEffect $ spawn cmd args defaultSpawnOptions
  liftEffect $ logStdOut cp
  waitExit cp

  liftEffect $ exit 0
