module Jelly.Data.Prop where

import Prelude

import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Effect (Effect)
import Jelly.Data.Signal (Signal)
import Web.Event.Event (Event, EventType)

data Prop context
  = PropAttribute String (Record context -> Signal (Maybe String))
  | PropHandler EventType (Record context -> Event -> Effect Unit)

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

instance AttrValue Int where
  toAttrValue = pure <<< show

instance AttrValue (Maybe Int) where
  toAttrValue = map show

instance AttrValue Number where
  toAttrValue = pure <<< show

instance AttrValue (Maybe Number) where
  toAttrValue = map show

instance AttrValue (Array String) where
  toAttrValue = pure <<< joinWith " "

instance AttrValue (Maybe (Array String)) where
  toAttrValue = map (joinWith " ")

class AttrValueWithContext context a where
  toAttrValueWithContext :: a -> Record context -> Maybe String

instance (AttrValue a) => AttrValueWithContext context a where
  toAttrValueWithContext a _ = toAttrValue a

else instance (AttrValue a) => AttrValueWithContext context (Record context -> a) where
  toAttrValueWithContext f context = toAttrValue $ f context

class AttrValueWithSignalAndContext context a where
  toAttrValueWithSignalAndContext :: a -> Record context -> Signal (Maybe String)

instance (AttrValue a) => AttrValueWithSignalAndContext context (Signal a) where
  toAttrValueWithSignalAndContext signal _ = map toAttrValue signal

else instance (AttrValue a) => AttrValueWithSignalAndContext context (Record context -> Signal a) where
  toAttrValueWithSignalAndContext f context = map toAttrValue $ f context

attr :: forall context a. AttrValueWithContext context a => String -> a -> Prop context
attr name signal = PropAttribute name \context -> pure $ toAttrValueWithContext signal context

infix 0 attr as :=

attrSig :: forall context a. AttrValueWithSignalAndContext context a => String -> a -> Prop context
attrSig name signal = PropAttribute name \context -> toAttrValueWithSignalAndContext signal context

on :: forall context. EventType -> (Event -> Effect Unit) -> Prop context
on et el = PropHandler et $ \_ -> el

onWithContext
  :: forall context. EventType -> (Record context -> Event -> Effect Unit) -> Prop context
onWithContext = PropHandler
