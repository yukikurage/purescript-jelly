module Jelly.Hooks.UseSignal where

import Prelude

import Effect (Effect)
import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Signal (Signal, launch)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

useSignal :: forall context. Signal (Effect (Effect Unit)) -> Hooks context Unit
useSignal sig = do
  useUnmountEffect =<< launch sig
