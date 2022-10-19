module Jelly.Hooks.UseAff where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Ref (modify_, new, read, write)
import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Signal (Signal, newState, newStateEq, writeAtom)
import Jelly.Hooks.UseEffect (useEffect)

useAff :: forall context a. a -> Signal (Aff a) -> Hooks context (Signal a)
useAff initial sig = do
  vSig /\ vAtom <- newState initial
  currentRef <- liftEffect $ new 0
  finishedRef <- liftEffect $ new 0
  useEffect $ sig <#> \aff -> do
    modify_ (_ + 1) currentRef
    current <- read currentRef -- 1, 2, 3 ...
    launchAff_ do
      v <- aff
      finished <- liftEffect $ read finishedRef
      if current > finished then do
        writeAtom vAtom v
        liftEffect $ write current finishedRef
      else pure unit
    mempty
  pure vSig

useAffEq :: forall context a. Eq a => a -> Signal (Aff a) -> Hooks context (Signal a)
useAffEq initial sig = do
  vSig /\ vAtom <- newStateEq initial
  currentRef <- liftEffect $ new 0
  finishedRef <- liftEffect $ new 0
  useEffect $ sig <#> \aff -> do
    modify_ (_ + 1) currentRef
    current <- read currentRef -- 1, 2, 3 ...
    launchAff_ do
      v <- aff
      finished <- liftEffect $ read finishedRef
      if current > finished then do
        writeAtom vAtom v
        liftEffect $ write current finishedRef
      else pure unit
    mempty
  pure vSig
