module Jelly.Render where

import Prelude

import Data.Array (fold)
import Data.Traversable (traverse)
import Effect (Effect)
import Jelly.Class.Platform (class NodeJS)
import Jelly.Data.Component (Component, runComponent)
import Jelly.Data.Emitter (newEmitter)
import Jelly.Data.Instance (toHTML)
import Jelly.Data.Signal (readSignal)

render :: forall context. NodeJS => Component context -> context -> Effect String
render component context = do
  unmountEmitter <- newEmitter
  insts <- readSignal =<< runComponent component { context, unmountEmitter }
  fold <$> traverse toHTML insts
