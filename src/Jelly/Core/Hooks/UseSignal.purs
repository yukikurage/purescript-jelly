module Jelly.Core.Hooks.UseSignal where

import Prelude

import Effect (Effect)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Data.Signal (Signal, listen)
import Jelly.Core.Hooks.UseUnmountEffect (useUnmountEffect)

useSignal :: forall context a. Signal a -> (a -> Effect (Effect Unit)) -> Hooks context Unit
useSignal sig lsn = useUnmountEffect =<< listen sig lsn
