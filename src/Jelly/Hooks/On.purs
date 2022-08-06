module Jelly.Hooks.On where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook, useRef)
import Web.DOM.Element (toEventTarget)
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)

on :: forall r. String -> (Event -> Effect Unit) -> Hook r Unit
on eventType listenerSig = do
  parentElement <- useRef

  liftEffect do
    listener <- eventListener \ev -> listenerSig ev
    addEventListener (EventType eventType) listener false
      (toEventTarget parentElement)
