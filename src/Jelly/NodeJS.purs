module Jelly.NodeJS where

import Prelude

import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Ref (new)
import Jelly.Class.Platform (class NodeJS)
import Jelly.Data.Component (Component, runComponent)
import Jelly.Data.Emitter (newEmitter)
import Jelly.Data.Instance (toHTML)
import Jelly.Data.Signal (readSignal)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (writeTextFile)
import Node.Path (FilePath)

render :: forall context. NodeJS => Component context -> context -> Effect String
render component context = do
  unmountEmitter <- newEmitter
  realNodeRef <- new Nothing
  insts <- readSignal =<< runComponent component { context, unmountEmitter, realNodeRef }
  fold <$> traverse toHTML insts

writeToFile :: FilePath -> String -> Aff Unit
writeToFile path content = writeTextFile UTF8 path content
