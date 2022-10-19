module Jelly.Hooks.UseHooks where

import Prelude

import Data.Tuple (fst, snd)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Jelly.Data.Hooks (Hooks, runHooks)
import Jelly.Data.Signal (Signal, newState, readSignal, writeAtom)
import Jelly.Hooks.UseContext (useContext)
import Jelly.Hooks.UseEffect (useEffect)

useHooks :: forall context a. Signal (Hooks context a) -> Hooks context (Signal a)
useHooks hooksSig = do
  context <- useContext
  initHook <- liftEffect $ readSignal hooksSig
  initV <- liftEffect $ runHooks initHook context
  vSig /\ vAtom <- liftEffect $ newState $ fst initV
  useEffect $ hooksSig <#> \hooks -> do
    v <- runHooks hooks context
    writeAtom vAtom $ fst v
    pure $ snd v
  pure vSig
