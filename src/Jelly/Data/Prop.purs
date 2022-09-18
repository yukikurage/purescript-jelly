module Jelly.Data.Prop where

import Prelude

import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Emitter (Emitter, addListener)
import Jelly.Data.Instance (Instance, addEventListener, removeAttribute, setAttribute)
import Jelly.Data.Signal (Signal, launch)
import Web.Event.Event (Event, EventType)

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

attr :: forall a. AttrValue a => String -> a -> Prop
attr name value = PropAttribute name $ pure $ toAttrValue value

infix 0 attr as :=

attrSig :: forall a. AttrValue a => String -> Signal a -> Prop
attrSig name signal = PropAttribute name $ map toAttrValue signal

infix 0 attrSig as :=#

on :: EventType -> (Event -> Effect Unit) -> Prop
on = PropHandler

registerProps :: Array Prop -> Emitter -> Instance -> Effect Unit
registerProps props unmountEmitter inst = do
  for_ props case _ of
    PropAttribute name signal ->
      addListener unmountEmitter =<< launch do
        value <- signal
        liftEffect case value of
          Just v -> setAttribute name v inst
          Nothing -> removeAttribute name inst
    PropHandler eventType handler -> do
      remove <- addEventListener eventType handler inst
      addListener unmountEmitter remove
