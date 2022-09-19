module Jelly.Hooks.UseEventListener where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hooks (Hooks)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)
import Web.Event.Event (EventType)
import Web.Event.EventTarget (EventTarget, addEventListener, addEventListenerWithOptions, eventListener, removeEventListener)
import Web.Event.Internal.Types (Event)

useEventListener
  :: forall r. EventType -> (Event -> Effect Unit) -> EventTarget -> Hooks r Unit
useEventListener eventType listener eventTarget = do
  l <- liftEffect $ eventListener listener

  liftEffect $ addEventListener eventType l false eventTarget

  useUnmountEffect
    $ removeEventListener eventType l false eventTarget

useEventListenerWithOption
  :: forall r
   . EventType
  -> (Event -> Effect Unit)
  -> { capture :: Boolean, once :: Boolean, passive :: Boolean }
  -> EventTarget
  -> Hooks r Unit
useEventListenerWithOption eventType listener options eventTarget = do
  l <- liftEffect $ eventListener listener

  liftEffect
    $ addEventListenerWithOptions eventType l options eventTarget

  useUnmountEffect
    $ removeEventListener eventType l options.capture eventTarget
