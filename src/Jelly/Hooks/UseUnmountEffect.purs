module Jelly.Hooks.UseUnmountEffect where

import Prelude

import Control.Monad.Reader (ask)
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Emitter (addListener)
import Jelly.Data.Hooks (Hooks)

useUnmountEffect :: forall context. Effect Unit -> Hooks context Unit
useUnmountEffect effect = do
  { unmountEmitter } <- ask
  liftEffect $ addListener unmountEmitter effect
