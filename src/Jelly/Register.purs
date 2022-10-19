module Jelly.Register where

import Prelude

import Data.Array (foldMap)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Jelly.Data.Prop (Prop(..))
import Jelly.Data.Signal (Signal, runSignal, runSignalWithoutInit)
import Web.DOM (Element, Node, Text)
import Web.DOM.Element (removeAttribute, setAttribute)
import Web.DOM.Element as Element
import Web.DOM.Node (setTextContent)
import Web.DOM.Text as Text
import Web.Event.EventTarget (addEventListener, eventListener)

foreign import updateChildren :: Node -> Array Node -> Effect Unit

foreign import setInnerHtml :: Element -> String -> Effect Unit

registerProp :: Element -> Prop -> Effect (Effect Unit)
registerProp element = case _ of
  PropAttribute name valueSig -> do
    runSignal $ valueSig <#> \value -> do
      case value of
        Nothing -> removeAttribute name element
        Just v -> setAttribute name v element
      mempty
  PropHandler eventType handler -> do
    el <- eventListener handler
    addEventListener eventType el false $ Element.toEventTarget element
    pure $ pure unit
  PropMountEffect effect -> do
    effect element
    mempty

registerProps :: Element -> Array Prop -> Effect (Effect Unit)
registerProps element props = foldMap (registerProp element) props

registerPropWithoutInit :: Element -> Prop -> Effect (Effect Unit)
registerPropWithoutInit element = case _ of
  PropAttribute name valueSig -> do
    runSignalWithoutInit $ valueSig <#> \value -> do
      case value of
        Nothing -> removeAttribute name element
        Just v -> setAttribute name v element
      mempty
  PropHandler eventType handler -> do
    el <- eventListener handler
    addEventListener eventType el false $ Element.toEventTarget element
    pure $ pure unit
  PropMountEffect effect -> do
    effect element
    mempty

registerPropsWithoutInit :: Element -> Array Prop -> Effect (Effect Unit)
registerPropsWithoutInit element props = foldMap (registerPropWithoutInit element) props

registerChildren :: Node -> Signal (Array Node) -> Effect (Effect Unit)
registerChildren elem chlSig = runSignal $ chlSig <#> \chl -> do
  updateChildren elem chl
  mempty

registerText :: Text -> Signal String -> Effect (Effect Unit)
registerText txt txtSig = runSignal $ txtSig <#> \tx -> do
  setTextContent tx $ Text.toNode txt
  mempty

registerInnerHtml :: Element -> Signal String -> Effect (Effect Unit)
registerInnerHtml elem htmlSig = runSignal $ htmlSig <#> \html -> do
  setInnerHtml elem html
  mempty
