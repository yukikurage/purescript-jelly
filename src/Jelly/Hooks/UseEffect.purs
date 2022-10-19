module Jelly.Hooks.UseEffect where

import Prelude

import Effect (Effect)
import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Signal (Signal, runSignal)
import Jelly.Hooks.UseCleanup (useCleanup)

useEffect :: forall context. Signal (Effect (Effect Unit)) -> Hooks context Unit
useEffect sig = do
  useCleanup =<< runSignal sig
