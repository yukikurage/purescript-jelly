module Jelly.Hooks.UseSignal where

import Prelude

import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal, launch)
import Jelly.Hooks.UseDeferSignal (useDeferSignal)

useSignal :: forall t11. Signal Unit -> Hook t11 Unit
useSignal signal = do
  stop <- liftEffect $ launch signal
  useDeferSignal $ liftEffect stop
