module Jelly.Register
  ( registerChildren
  , registerInnerHtml
  , registerProp
  , registerProps
  , registerText
  ) where

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

runSignalRegister
  :: Boolean -> Signal (Effect (Effect Unit)) -> Effect (Effect Unit)
runSignalRegister doInitialize = if doInitialize then runSignal else runSignalWithoutInit

registerProp :: Boolean -> Element -> Prop -> Effect (Effect Unit)
registerProp doInitialize element = case _ of
  PropAttribute name valueSig -> do
    runSignalRegister doInitialize $ valueSig <#> \value -> do
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

registerProps :: Boolean -> Element -> Array Prop -> Effect (Effect Unit)
registerProps doInitialize element props = foldMap (registerProp doInitialize element) props

registerChildren :: Boolean -> Node -> Signal (Array Node) -> Effect (Effect Unit)
registerChildren doInitialize elem chlSig =
  runSignalRegister doInitialize $ chlSig <#> \chl -> do
    updateChildren elem chl
    mempty

registerText :: Boolean -> Text -> Signal String -> Effect (Effect Unit)
registerText doInitialize txt txtSig = runSignalRegister doInitialize $
  txtSig <#> \tx -> do
    setTextContent tx $ Text.toNode txt
    mempty

registerInnerHtml :: Boolean -> Element -> Signal String -> Effect (Effect Unit)
registerInnerHtml doInitialize elem htmlSig =
  runSignalRegister doInitialize $ htmlSig <#> \html -> do
    setInnerHtml elem html
    mempty
