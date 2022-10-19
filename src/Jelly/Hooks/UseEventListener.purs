module Jelly.Hooks.UseEventListener where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hooks (Hooks)
import Jelly.Hooks.UseCleanup (useCleanup)
import Web.Event.Event (EventType)
import Web.Event.EventTarget (EventTarget, addEventListener, eventListener, removeEventListener)
import Web.Event.Internal.Types (Event)

useEventListener
  :: forall r. EventType -> (Event -> Effect Unit) -> EventTarget -> Hooks r Unit
useEventListener eventType listener eventTarget = do
  l <- liftEffect $ eventListener listener

  liftEffect $ addEventListener eventType l false eventTarget

  useCleanup $ removeEventListener eventType l false eventTarget
