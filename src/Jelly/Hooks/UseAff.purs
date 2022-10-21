module Jelly.Hooks.UseAff where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff)
import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Signal (Signal, unwrapAffSignal, unwrapAffSignalEq)
import Jelly.Hooks.UseCleanup (useCleanup)

useAff :: forall context a. a -> Signal (Aff a) -> Hooks context (Signal a)
useAff initial sig = do
  vSig /\ cleanup <- unwrapAffSignal initial sig
  useCleanup cleanup
  pure vSig

useAffEq :: forall context a. Eq a => a -> Signal (Aff a) -> Hooks context (Signal a)
useAffEq initial sig = do
  vSig /\ cleanup <- unwrapAffSignalEq initial sig
  useCleanup cleanup
  pure vSig

useAff_ :: forall context. Signal (Aff Unit) -> Hooks context Unit
useAff_ sig = do
  _ /\ cleanup <- unwrapAffSignalEq unit sig
  useCleanup cleanup
