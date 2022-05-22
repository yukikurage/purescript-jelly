module Jelly.Hooks.UseUnmountEffect where

import Prelude

import Control.Monad.Reader (ask, runReaderT)
import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.Emitter (addEmitterListener, newEmitterListener)
import Jelly.Data.HookM (HookM(..))
import Jelly.Data.JellyM (JellyM(..))

useUnmountEffect :: forall m. MonadEffect m => JellyM m Unit -> HookM m Unit
useUnmountEffect (JellyM resolve) = HookM do
  listener <- liftEffect $ newEmitterListener $ \_ -> runReaderT resolve Nothing
  { unmountEmitter } <- ask
  liftEffect $ addEmitterListener unmountEmitter listener
