module Jelly.Core.Render where

import Prelude

import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Ref (new)
import Jelly.Core.Data.Component (Component, runComponent)
import Jelly.Core.Data.Instance (toHTML)
import Jelly.Core.Data.Signal (readSignal)

render :: Component () -> Effect String
render component = do
  realInstanceRef <- new Nothing
  { instancesSig, unmountEffect } <- runComponent component { context: {}, realInstanceRef }
  unmountEffect
  instances <- readSignal instancesSig
  fold <$> traverse toHTML instances
