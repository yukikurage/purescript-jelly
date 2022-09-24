module Jelly.Core.Hooks.UseEventListener where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Hooks.UseUnmountEffect (useUnmountEffect)
import Web.Event.Event (EventType)
import Web.Event.EventTarget (EventTarget, addEventListener, eventListener, removeEventListener)
import Web.Event.Internal.Types (Event)

useEventListener
  :: forall r. EventType -> (Event -> Effect Unit) -> EventTarget -> Hooks r Unit
useEventListener eventType listener eventTarget = do
  l <- liftEffect $ eventListener listener

  liftEffect $ addEventListener eventType l false eventTarget

  useUnmountEffect $ removeEventListener eventType l false eventTarget
