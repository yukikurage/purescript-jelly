module Jelly.Core.Hooks.UseAffSignal where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Ref (modify_, new, read, write)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Data.Signal (Signal, send, signal)
import Jelly.Core.Hooks.UseSignal (useSignal)

useAffSignal :: forall context a. Signal (Aff a) -> Hooks context (Signal (Maybe a))
useAffSignal sig = do
  vSig /\ vAtom <- signal Nothing
  currentRef <- liftEffect $ new 0
  finishedRef <- liftEffect $ new 0
  useSignal $ sig <#> \aff -> do
    modify_ (_ + 1) currentRef
    current <- read currentRef -- 1, 2, 3 ...
    launchAff_ do
      v <- aff
      finished <- liftEffect $ read finishedRef
      if current > finished then do
        send vAtom $ Just v
        liftEffect $ write current finishedRef
      else pure unit
    mempty
  pure vSig
