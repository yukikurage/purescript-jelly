module Jelly.Data.Prop where

import Prelude

import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Emitter (Emitter, addListener)
import Jelly.Data.Signal (Signal, launch)
import Web.DOM (Element)
import Web.DOM.Element (removeAttribute, setAttribute)
import Web.DOM.Element as Element
import Web.Event.Event (Event, EventType)
import Web.Event.EventTarget (addEventListener, eventListener, removeEventListener)

data Prop
  = PropAttribute String (Signal (Maybe String))
  | PropHandler EventType (Event -> Effect Unit)

justPropAttribute :: String -> Signal String -> Prop
justPropAttribute name = PropAttribute name <<< map Just

infix 0 PropAttribute as ?:=
infix 0 justPropAttribute as :=

on :: EventType -> (Event -> Effect Unit) -> Prop
on = PropHandler

registerProps :: Array Prop -> Emitter -> Element -> Effect Unit
registerProps props unmountEmitter element = do
  for_ props case _ of
    PropAttribute name signal ->
      addListener unmountEmitter =<< launch do
        value <- signal
        liftEffect case value of
          Just v -> setAttribute name v element
          Nothing -> removeAttribute name element
    PropHandler eventType handler -> do
      let
        et = Element.toEventTarget element
      listener <- eventListener handler
      addEventListener eventType listener false et
      addListener unmountEmitter $ removeEventListener eventType listener false et
