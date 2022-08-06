module Jelly.Hooks.UseSignal where

import Prelude

import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook, useUnmountEffect)
import Jelly.Data.Signal (Signal, launch)

useSignal :: forall r. Signal Unit -> Hook r Unit
useSignal signal = useUnmountEffect =<< liftEffect (launch signal)
