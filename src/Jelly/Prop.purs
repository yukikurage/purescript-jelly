module Jelly.Prop where

import Prelude

import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Jelly.Signal (Signal)
import Web.DOM (Element)
import Web.Event.Event (Event, EventType)

-- | Prop represents one property of a DOM element.
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

-- | Create a property
attr :: forall m a. AttrValue a => String -> a -> Prop m
attr name value = PropAttribute name $ pure $ toAttrValue value

infix 0 attr as :=

-- | Create a property with a Signal
attrSig :: forall m a. AttrValue a => String -> Signal a -> Prop m
attrSig name value = PropAttribute name $ toAttrValue <$> value

infix 0 attrSig as @=

-- | Set an event handler for the given event type.
on :: forall m. EventType -> (Event -> m Unit) -> Prop m
on = PropHandler

-- | Set an effect to run when the element is mounted.
onMount :: forall m. (Element -> m Unit) -> Prop m
onMount = PropMountEffect

-- | Render a prop
renderProp :: forall m. Prop m -> Signal String
renderProp = case _ of
  PropAttribute name valueSig -> do
    value <- valueSig
    pure case value of
      Nothing -> ""
      Just v -> " " <> name <> "=\"" <> v <> "\""
  PropHandler _ _ -> pure ""
  PropMountEffect _ -> pure ""

-- | Render a list of props
renderProps :: forall m. Array (Prop m) -> Signal String
renderProps props = fold $ map renderProp props
