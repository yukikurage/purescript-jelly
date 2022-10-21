module Jelly.Hooks.UseEffect where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Signal (Signal, unwrapEffectSignal, unwrapEffectSignalEq)
import Jelly.Hooks.UseCleanup (useCleanup)

useEffect :: forall context a. Signal (Effect a) -> Hooks context (Signal a)
useEffect sig = do
  vSig /\ cleanup <- unwrapEffectSignal sig
  useCleanup cleanup
  pure vSig

useEffectEq :: forall context a. Eq a => Signal (Effect a) -> Hooks context (Signal a)
useEffectEq sig = do
  vSig /\ cleanup <- unwrapEffectSignalEq sig
  useCleanup cleanup
  pure vSig

useEffect_ :: forall context. Signal (Effect Unit) -> Hooks context Unit
useEffect_ sig = do
  _ /\ cleanup <- unwrapEffectSignalEq sig
  useCleanup cleanup
