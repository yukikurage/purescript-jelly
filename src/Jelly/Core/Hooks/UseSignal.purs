module Jelly.Core.Hooks.UseSignal where

import Prelude

import Effect (Effect)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Data.Signal (Signal, run)
import Jelly.Core.Hooks.UseUnmountEffect (useUnmountEffect)

useSignal :: forall context. Signal (Effect (Effect Unit)) -> Hooks context Unit
useSignal sig = do
  useUnmountEffect =<< run sig
