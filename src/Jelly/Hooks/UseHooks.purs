module Jelly.Hooks.UseHooks where

import Prelude

import Data.Tuple.Nested ((/\))
import Jelly.Data.Hooks (Hooks, runHooks)
import Jelly.Data.Signal (Signal, launchSignal)
import Jelly.Hooks.UseCleanup (useCleanup)
import Jelly.Hooks.UseContext (useContext)

useHooks :: forall context a. Signal (Hooks context a) -> Hooks context (Signal a)
useHooks hooksSig = do
  context <- useContext
  vSig /\ cleanup <- launchSignal $ hooksSig <#> \hooks -> runHooks hooks context
  useCleanup cleanup
  pure vSig
