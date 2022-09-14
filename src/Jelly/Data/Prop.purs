module Jelly.Data.Prop where

import Prelude

import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Emitter (Emitter, addListener)
import Jelly.Data.Instance (Instance, addEventListener, removeAttribute, setAttribute)
import Jelly.Data.Signal (Signal, launch)
import Web.Event.Event (Event, EventType)

data Prop
  = PropAttribute String (Signal (Maybe String))
  | PropHandler EventType (Event -> Effect Unit)

justPropAttribute :: String -> Signal String -> Prop
justPropAttribute name = PropAttribute name <<< map Just

infix 0 PropAttribute as ?:=
infix 0 justPropAttribute as :=

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
