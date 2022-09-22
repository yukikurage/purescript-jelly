module Jelly.Hooks.UseSignal where

import Prelude

import Effect.Class (liftEffect)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Data.Signal (Signal, launch)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

useSignal :: forall context. Signal Unit -> Hooks context Unit
useSignal sig = do
  useUnmountEffect =<< liftEffect (launch sig)
