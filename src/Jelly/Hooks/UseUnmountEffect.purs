module Jelly.Hooks.UseUnmountEffect where

import Prelude

import Control.Monad.Reader (ask, runReaderT)
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Jelly.Data.Emitter (addEmitterListenerOnce)
import Jelly.Data.HookM (HookM(..))
import Jelly.Data.JellyM (JellyM(..))

useUnmountEffect :: forall r. JellyM Unit -> HookM r Unit
useUnmountEffect (JellyM resolve) = HookM do
  { unmountEmitter } <- ask
  _ <- liftEffect $ addEmitterListenerOnce unmountEmitter \_ -> runReaderT
    resolve
    Nothing
  pure unit
