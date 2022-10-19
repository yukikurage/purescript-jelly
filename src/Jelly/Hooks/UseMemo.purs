module Jelly.Hooks.UseMemo where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Signal (Signal, newState, newStateEq, readSignal, writeAtom)
import Jelly.Hooks.UseEffect (useEffect)

useMemo :: forall context a. Signal (Effect a) -> Hooks context (Signal a)
useMemo sig = do
  vSig /\ vAtom <- liftEffect $ newState =<< join (readSignal sig)
  useEffect $ sig <#> \eff -> do
    writeAtom vAtom =<< eff
    mempty
  pure vSig

useMemoEq :: forall context a. Eq a => Signal (Effect a) -> Hooks context (Signal a)
useMemoEq sig = do
  vSig /\ vAtom <- liftEffect $ newStateEq =<< join (readSignal sig)
  useEffect $ sig <#> \eff -> do
    writeAtom vAtom =<< eff
    mempty
  pure vSig
