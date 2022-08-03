module Jelly.Hooks.UseSignal where

import Prelude

import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal, launch)
import Jelly.Hooks.UseUnmountSignal (useUnmountSignal)

useSignal :: forall r. Signal Unit -> Hook r Unit
useSignal signal = do
  stop <- liftEffect $ launch signal
  useUnmountSignal $ liftEffect stop
