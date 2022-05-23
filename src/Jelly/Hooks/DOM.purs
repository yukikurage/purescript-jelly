module Jelly.Hooks.DOM where

import Prelude

import Data.Foldable (for_)
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.HookM (HookM)
import Jelly.Data.JellyM (JellyM, alone)
import Jelly.Data.Props (Prop(..))
import Jelly.Hooks.UseEffect (useEffect)
import Web.DOM (Element, Node)
import Web.DOM.Document (createTextNode)
import Web.DOM.Element (setAttribute, toEventTarget)
import Web.DOM.Node (setTextContent)
import Web.DOM.Text as Text
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML (window)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.Window (document)

setProps :: forall m. MonadEffect m => Element -> Array Prop -> HookM m Unit
setProps element props = do
  for_ props case _ of
    PropAttribute name valueJelly -> do
      useEffect do
        value <- valueJelly
        liftEffect $ setAttribute name value element
        pure $ pure unit
    PropListener name listenerJelly -> do
      listener <- liftEffect $ eventListener \e -> alone $ listenerJelly e
      liftEffect $ addEventListener (EventType name) listener false $
        toEventTarget element

-- el :: forall m. MonadEffect m => String -> Array (Prop m) -> Array (HookM m Node) -> HookM m Element

text :: forall m. MonadEffect m => JellyM String -> HookM m Node
text strM = do
  node <- liftEffect $ Text.toNode <$>
    ( createTextNode "" <<< HTMLDocument.toDocument
        =<< document
        =<< window
    )

  useEffect do
    str <- strM
    liftEffect $ setTextContent str node
    pure $ pure unit

  pure node

-- element :: forall m. MonadEffect m => String -> Array () -> Children -> HookM m Element
-- putAt
