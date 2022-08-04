module Jelly.Hooks.UseSignal where

import Prelude

import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal, launch)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

useSignal :: forall r. Signal Unit -> Hook r Unit
useSignal signal = useUnmountEffect =<< liftEffect (launch signal)
