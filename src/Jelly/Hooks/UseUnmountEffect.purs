module Jelly.Hooks.UseUnmountEffect where

import Prelude

import Control.Monad.Reader (ask, runReaderT)
import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.Emitter (addEmitterListenerOnce)
import Jelly.Data.HookM (HookM(..))
import Jelly.Data.JellyM (JellyM(..))

useUnmountEffect :: forall m. MonadEffect m => JellyM m Unit -> HookM m Unit
useUnmountEffect (JellyM resolve) = HookM do
  { unmountEmitter } <- ask
  _ <- liftEffect $ addEmitterListenerOnce unmountEmitter \_ -> runReaderT
    resolve
    Nothing
  pure unit
