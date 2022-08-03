module Jelly.Hooks.On where

import Prelude

import Control.Monad.Reader (ask)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal, detach)
import Web.DOM.Element (toEventTarget)
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)

on :: forall r. String -> (Event -> Signal Unit) -> Hook r Unit
on eventType listenerSig = do
  { parentElement } <- ask

  liftEffect do
    listener <- eventListener \ev -> detach $ listenerSig ev
    addEventListener (EventType eventType) listener false
      (toEventTarget parentElement)
