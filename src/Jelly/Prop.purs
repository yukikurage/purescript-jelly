module Jelly.Prop where

import Prelude

import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Signal (Signal, readSignal)
import Signal.Hooks (Hooks)
import Web.DOM (Element)
import Web.Event.Event (Event, EventType)

data Prop context
  = PropAttribute String (Signal (Maybe String))
  | PropHandler EventType (Event -> Hooks context Unit)
  | PropMountEffect (Element -> Hooks context Unit)

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

instance AttrValue (Array String) where
  toAttrValue = Just <<< fold <<< map (\s -> s <> " ")

instance AttrValue (Maybe (Array String)) where
  toAttrValue v = toAttrValue =<< v

attr :: forall context a. AttrValue a => String -> a -> Prop context
attr name value = PropAttribute name $ pure $ toAttrValue value

infix 0 attr as :=

attrSig :: forall context a. AttrValue a => String -> Signal a -> Prop context
attrSig name value = PropAttribute name $ toAttrValue <$> value

infix 0 attrSig as :=@

on :: forall context. EventType -> (Event -> Hooks context Unit) -> Prop context
on = PropHandler

onMount :: forall context. (Element -> Hooks context Unit) -> Prop context
onMount = PropMountEffect

renderProp :: forall context. Prop context -> Effect String
renderProp = case _ of
  PropAttribute name valueSig -> do
    value <- readSignal valueSig
    pure case value of
      Nothing -> ""
      Just v -> " " <> name <> "=\"" <> v <> "\""
  PropHandler _ _ -> pure ""
  PropMountEffect _ -> pure ""

renderProps :: forall context. Array (Prop context) -> Effect String
renderProps props = fold $ map renderProp props
