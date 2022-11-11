module Jelly.Prop where

import Prelude

import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Jelly.Signal (Signal, readSignal)
import Web.DOM (Element)
import Web.Event.Event (Event, EventType)

data Prop m
  = PropAttribute String (Signal (Maybe String))
  | PropHandler EventType (Event -> m Unit)
  | PropMountEffect (Element -> m Unit)

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

hoistProp :: forall m n. (m ~> n) -> Prop m -> Prop n
hoistProp f = case _ of
  PropAttribute name value -> PropAttribute name value
  PropHandler eventType handler -> PropHandler eventType (f <<< handler)
  PropMountEffect effect -> PropMountEffect (f <<< effect)

attr :: forall m a. AttrValue a => String -> a -> Prop m
attr name value = PropAttribute name $ pure $ toAttrValue value

infix 0 attr as :=

attrSig :: forall m a. AttrValue a => String -> Signal a -> Prop m
attrSig name value = PropAttribute name $ toAttrValue <$> value

infix 0 attrSig as :=@

on :: forall m. EventType -> (Event -> m Unit) -> Prop m
on = PropHandler

onMount :: forall m. (Element -> m Unit) -> Prop m
onMount = PropMountEffect

renderProp :: forall m. Prop m -> Effect String
renderProp = case _ of
  PropAttribute name valueSig -> do
    value <- readSignal valueSig
    pure case value of
      Nothing -> ""
      Just v -> " " <> name <> "=\"" <> v <> "\""
  PropHandler _ _ -> pure ""
  PropMountEffect _ -> pure ""

renderProps :: forall m. Array (Prop m) -> Effect String
renderProps props = fold $ map renderProp props
