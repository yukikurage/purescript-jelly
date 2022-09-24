module Jelly.Core.Data.Prop where

import Prelude

import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Jelly.Core.Data.Signal (Signal, get, listen)
import Web.DOM (Element)
import Web.DOM.Element (removeAttribute, setAttribute)
import Web.DOM.Element as Element
import Web.Event.Event (Event, EventType)
import Web.Event.EventTarget (addEventListener, eventListener)

data Prop
  = PropAttribute String (Signal (Maybe String))
  | PropHandler EventType (Event -> Effect Unit)

class AttrValue a where
  toAttrValue :: a -> Maybe String

instance AttrValue String where
  toAttrValue = Just

instance AttrValue (Maybe String) where
  toAttrValue = identity

instance AttrValue Boolean where
  toAttrValue v = if v then Just "" else Nothing

instance AttrValue (Maybe Boolean) where
  toAttrValue v = toAttrValue =<< v

attr :: forall a. AttrValue a => String -> a -> Prop
attr name value = PropAttribute name $ pure $ toAttrValue value

infix 0 attr as :=

attrSig :: forall a. AttrValue a => String -> Signal a -> Prop
attrSig name value = PropAttribute name $ toAttrValue <$> value

infix 0 attrSig as :=@

on :: EventType -> (Event -> Effect Unit) -> Prop
on = PropHandler

renderProp :: Prop -> Effect String
renderProp = case _ of
  PropAttribute name valueSig -> do
    value <- get valueSig
    pure case value of
      Nothing -> ""
      Just v -> " " <> name <> "=\"" <> v <> "\""
  PropHandler _ _ -> pure ""

renderProps :: Array Prop -> Effect String
renderProps props = fold $ map renderProp props

registerProp :: Element -> Prop -> Effect (Effect Unit)
registerProp element = case _ of
  PropAttribute name valueSig -> do
    listen valueSig \value -> do
      case value of
        Nothing -> removeAttribute name element
        Just v -> setAttribute name v element
      mempty
  PropHandler eventType handler -> do
    el <- eventListener handler
    addEventListener eventType el false $ Element.toEventTarget element
    mempty

registerProps :: Element -> Array Prop -> Effect (Effect Unit)
registerProps element props = do
  unregisters <- traverse (registerProp element) props
  pure $ fold unregisters
