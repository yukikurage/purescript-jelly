module Jelly.HTML where

import Prelude

import Control.Monad.Reader (ask)
import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Jelly.Data.Hooks (Hooks, runHooks)
import Jelly.Data.Jelly (Jelly, alone)
import Jelly.Data.Jelly.Class (liftJelly)
import Jelly.Data.Props (Prop(..))
import Jelly.Hooks.UseJelly (useJelly)
import Jelly.Hooks.UseUnmountJelly (useUnmountJelly)
import Web.DOM (Element, Node)
import Web.DOM.Document (createElement, createElementNS, createTextNode)
import Web.DOM.Element (setAttribute, toEventTarget, toNode)
import Web.DOM.Node (appendChild, insertBefore, removeChild, setTextContent)
import Web.DOM.Text as Text
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

type Component r = Hooks r Unit

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

addNode :: forall r. Node -> Component r
addNode node = do
  { parentNode, anchorNode } <- ask

  -- Append Element to Parent
  liftEffect case anchorNode of
    Nothing -> appendChild node parentNode
    Just an -> insertBefore node an parentNode

  -- Add Unmount Effect
  useUnmountJelly $ liftEffect $ removeChild node parentNode

-- | Create element
el :: forall r. String -> Array Prop -> Component r -> Component r
el tagName props childComponent = do
  -- Create Element
  element <- liftEffect $ createElement tagName <<< toDocument =<< document =<<
    window

  -- Set Props
  for_ props $ setProp element

  { contexts } <- ask

  -- Add Node to Parent Node
  addNode $ toNode element

  -- Add Children
  liftJelly $ runHooks
    { parentNode: toNode element, contexts, anchorNode: Nothing }
    childComponent

-- | Create element with namespace
elNS
  :: forall r
   . String
  -> String
  -> Array Prop
  -> Component r
  -> Component r
elNS ns tagName props childComponent = do
  element <- liftEffect $ createElementNS (Just ns) tagName <<< toDocument
    =<< document
    =<<
      window

  -- Set Props
  for_ props $ setProp element

  { contexts } <- ask

  -- Add Node to Parent Node
  addNode $ toNode element

  -- Add Children
  liftJelly $ runHooks
    { parentNode: toNode element, contexts, anchorNode: Nothing }
    childComponent

-- | Create element without props
el_ :: forall r. String -> Component r -> Component r
el_ tagName = el tagName []

elNS_ :: forall r. String -> String -> Component r -> Component r
elNS_ ns tagName = elNS ns tagName []

-- | Create empty element (== text $ pure "")
elEmpty :: forall r. Component r
elEmpty = pure unit

-- | Display components only when conditions are met
elWhen :: forall r. Jelly Boolean -> Component r -> Component r
elWhen conditionJelly childJelly = elIf conditionJelly childJelly elEmpty

elIf :: forall r. Jelly Boolean -> Component r -> Component r -> Component r
elIf conditionJelly firstChildComponent secondChildComponent = do
  -- Create Anchor Node, which will be used to insert element
  anchorNode <- liftEffect $ Text.toNode <$>
    ( createTextNode "" <<< toDocument
        =<< document
        =<< window
    )

  -- Copy without anchor node
  { parentNode, contexts } <- ask

  -- Add Anchor Node to parent Node
  addNode anchorNode

  let hooksInternal = { parentNode, contexts, anchorNode: Just anchorNode }

  useJelly do
    -- Ref condition
    condition <- conditionJelly

    if condition then runHooks hooksInternal firstChildComponent
    else runHooks hooksInternal secondChildComponent

-- elFor :: forall r. Jelly (Array a) -> (Jelly a -> Component r) -> Component r

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

  addNode node
