module Jelly.Core.Render where

import Prelude

import Data.Array (fold)
import Data.Traversable (traverse)
import Effect (Effect)
import Jelly.Core.Data.Component (Component, runComponent)
import Jelly.Core.Data.Instance (toHTML)
import Jelly.Core.Data.Signal (readSignal)

render :: Component () -> Effect String
render component = do
  { instancesSig, unmountEffect } <- runComponent component { context: {} }
  unmountEffect
  instances <- readSignal instancesSig
  fold <$> traverse toHTML instances
