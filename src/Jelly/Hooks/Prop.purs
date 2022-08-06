module Jelly.Hooks.Prop where

import Prelude

import Jelly.Data.Hook (Hook, useModifyProp)
import Jelly.Data.Signal (Signal)

setProp :: forall r. String -> Signal String -> Hook r Unit
setProp key valueSig = useModifyProp key $ const valueSig

infix 1 setProp as :=

appendProp :: forall r. String -> Signal String -> Hook r Unit
appendProp key valueSig = useModifyProp key $ \prevSig -> do
  prev <- prevSig
  value <- valueSig
  pure $ prev <> value

infix 1 appendProp as :+
