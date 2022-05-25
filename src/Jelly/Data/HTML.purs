module Jelly.HTML where

import Prelude

import Control.Monad.Reader (ask)
import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Data.Hooks (Hooks, liftJelly, runHooks)
import Jelly.Data.Jelly (Jelly, alone)
import Jelly.Data.Props (Prop(..))
import Jelly.Hooks.UseJelly (useJelly)
import Web.DOM (Element, Node)
import Web.DOM.Document (createElement, createTextNode)
import Web.DOM.Element (setAttribute, toEventTarget, toNode)
import Web.DOM.Node (appendChild, insertBefore, removeChild, setTextContent)
import Web.DOM.Text as Text
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

type Component r = Hooks r Node

-- | [Internal] Set prop to element.
setProp :: forall r. Element -> Prop -> Hooks r Unit
setProp element prop = do
  case prop of
    PropAttribute name valueJelly -> do
      useJelly do
        value <- valueJelly
        liftEffect $ setAttribute name value element
    PropListener name listenerJelly -> do
      listener <-
        liftEffect $ eventListener \e -> alone $ listenerJelly e

      liftEffect $ addEventListener (EventType name) listener false $
        toEventTarget element

-- | [Internal] Add child to element.
addChild :: forall r. Node -> Component r -> Hooks r Unit
addChild parentNode nodeComponent = do
  oldNodeRef <- liftEffect $ new Nothing

  context <- ask

  useJelly do
    oldNodeMaybe <- liftEffect $ read oldNodeRef
    newNode <- runHooks context nodeComponent

    liftEffect case oldNodeMaybe of
      Nothing -> do
        appendChild newNode parentNode
      Just oldNode -> do
        insertBefore newNode oldNode parentNode
        removeChild oldNode parentNode
    liftEffect $ write (Just newNode) oldNodeRef

-- | Create element
el :: forall r. String -> Array Prop -> Array (Component r) -> Component r
el tagName props children = do
  element <- liftEffect $ createElement tagName <<< toDocument =<< document =<<
    window
  for_ props $ setProp element
  for_ children $ addChild $ toNode element
  pure $ toNode element

-- | Create element without props
el_ :: forall r. String -> Array (Component r) -> Component r
el_ tagName children = el tagName [] children

-- | Create empty element (== text $ pure "")
emptyEl :: forall r. Component r
emptyEl = text $ pure ""

-- | Display components only when conditions are met
whenEl :: forall r. Jelly Boolean -> Component r -> Component r
whenEl conditionJelly childJelly = do
  condition <- liftJelly conditionJelly
  if condition then childJelly
  else emptyEl

-- | Equal to `ifM`
ifEl :: forall r. Jelly Boolean -> Component r -> Component r -> Component r
ifEl a x y = do
  condition <- liftJelly a
  if condition then x else y

-- | Create text node
text :: forall r. Jelly String -> Component r
text txtJelly = do
  node <- liftEffect $ Text.toNode <$>
    ( createTextNode "" <<< toDocument
        =<< document
        =<< window
    )

  useJelly do
    txt <- txtJelly
    liftEffect $ setTextContent txt node
    pure unit

  pure node
