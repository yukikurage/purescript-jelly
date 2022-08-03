module Jelly.Hooks.UseUnmountSignal where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.ST.Global (toEffect)
import Data.Array.ST (push)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal, detach)

useUnmountSignal :: forall r. Signal Unit -> Hook r Unit
useUnmountSignal defer = do
  { unmountEffectsRef } <- ask
  liftEffect $ toEffect $ push (detach defer) unmountEffectsRef $> unit
