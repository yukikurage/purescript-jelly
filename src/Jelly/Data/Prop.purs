module Jelly.Data.Prop where

import Prelude

import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Jelly.Data.Signal (Signal, readSignal)
import Web.DOM (Element)
import Web.Event.Event (Event, EventType)

data Prop
  = PropAttribute String (Signal (Maybe String))
  | PropHandler EventType (Event -> Effect Unit)
  | PropMountEffect (Element -> Effect Unit)

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

attr :: forall a. AttrValue a => String -> a -> Prop
attr name value = PropAttribute name $ pure $ toAttrValue value

infix 0 attr as :=

attrSig :: forall a. AttrValue a => String -> Signal a -> Prop
attrSig name value = PropAttribute name $ toAttrValue <$> value

infix 0 attrSig as :=@

on :: EventType -> (Event -> Effect Unit) -> Prop
on = PropHandler

onMount :: (Element -> Effect Unit) -> Prop
onMount = PropMountEffect

renderProp :: Prop -> Effect String
renderProp = case _ of
  PropAttribute name valueSig -> do
    value <- readSignal valueSig
    pure case value of
      Nothing -> ""
      Just v -> " " <> name <> "=\"" <> v <> "\""
  PropHandler _ _ -> pure ""
  PropMountEffect _ -> pure ""

renderProps :: Array Prop -> Effect String
renderProps props = fold $ map renderProp props
