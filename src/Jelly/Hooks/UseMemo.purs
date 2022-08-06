module Jelly.Hooks.UseMemo where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal, readSignal, signal, writeAtom)
import Jelly.Hooks.UseSignal (useSignal)

useMemo :: forall r a. Eq a => Signal a -> Hook r (Signal a)
useMemo sig = do
  initValue <- liftEffect $ readSignal sig

  memoStateSig /\ memoStateAtom <- signal initValue

  useSignal do
    v <- sig
    liftEffect $ writeAtom memoStateAtom v

  pure memoStateSig
