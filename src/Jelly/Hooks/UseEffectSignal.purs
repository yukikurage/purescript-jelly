module Jelly.Hooks.UseEffectSignal where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Signal (Signal, get, send, signal)
import Jelly.Hooks.UseSignal (useSignal)

useEffectSignal :: forall context a. Signal (Effect a) -> Hooks context (Signal a)
useEffectSignal sig = do
  vSig /\ vAtom <- liftEffect $ signal =<< join (get sig)
  useSignal $ sig <#> \eff -> do
    send vAtom =<< eff
    mempty
  pure vSig
