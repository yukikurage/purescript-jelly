module Jelly.Hooks.UseMemo where

import Prelude

import Data.Tuple.Nested ((/\))
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Data.Signal (Signal, readSignal, signal, writeAtom)
import Jelly.Hooks.UseSignal (useSignal)

useMemo :: forall context a. Eq a => Signal a -> Hooks context (Signal a)
useMemo sig = do
  valSig /\ valAtom <- signal =<< readSignal sig

  useSignal do
    val <- valSig
    writeAtom valAtom val

  pure valSig
