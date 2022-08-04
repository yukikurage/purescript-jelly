module Jelly.Hooks.UseEventListener where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (EventTarget, addEventListener, addEventListenerWithOptions, eventListener, removeEventListener)
import Web.Event.Internal.Types (Event)

useEventListener
  :: forall r. String -> (Event -> Effect Unit) -> EventTarget -> Hook r Unit
useEventListener eventType listener eventTarget = do
  l <- liftEffect $ eventListener listener

  liftEffect $ addEventListener (EventType eventType) l false eventTarget

  useUnmountEffect
    $ removeEventListener (EventType eventType) l false eventTarget

useEventListenerWithOption
  :: forall r
   . String
  -> (Event -> Effect Unit)
  -> { capture :: Boolean, once :: Boolean, passive :: Boolean }
  -> EventTarget
  -> Hook r Unit
useEventListenerWithOption eventType listener options eventTarget = do
  l <- liftEffect $ eventListener listener

  liftEffect
    $ addEventListenerWithOptions (EventType eventType) l options eventTarget

  useUnmountEffect
    $ removeEventListener (EventType eventType) l options.capture eventTarget
