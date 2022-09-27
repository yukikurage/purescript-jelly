module Jelly.Core.Register where

import Prelude

registerPropSig :: Element -> Prop -> Signal (Effect (Effect Unit))
registerPropSig element = case _ of
  PropAttribute name valueSig -> do
    valueSig <#> \value -> do
      case value of
        Nothing -> removeAttribute name element
        Just v -> setAttribute name v element
      mempty
  PropHandler eventType handler -> pure do
    el <- eventListener handler
    addEventListener eventType el false $ Element.toEventTarget element
    mempty

registerPropsSig :: Element -> Array Prop -> Signal (Effect (Effect Unit))
registerPropsSig element props = foldMap (registerPropSig element) props
