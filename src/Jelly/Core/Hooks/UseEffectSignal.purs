module Jelly.Core.Hooks.UseEffectSignal where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Data.Signal (Signal, get, send, signal)
import Jelly.Core.Hooks.UseSignal (useSignal)

useEffectSignal :: forall context a. Signal (Effect a) -> Hooks context (Signal a)
useEffectSignal sig = do
  vSig /\ vAtom <- liftEffect $ signal =<< join (get sig)
  useSignal $ sig <#> \eff -> do
    send vAtom =<< eff
    mempty
  pure vSig
