module Jelly.HTML where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.Rec.Class (whileJust)
import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Data.Hooks (Hooks, runHooks)
import Jelly.Data.Jelly (Jelly, alone)
import Jelly.Data.Props (Prop(..))
import Jelly.Hooks.UseJelly (useJelly)
import Jelly.Hooks.UseNodesJelly (useNodeJelly, useNodesJelly)
import Jelly.Hooks.UseUnmountJelly (useUnmountJelly)
import Web.DOM (Element, Node)
import Web.DOM.Document (createElement, createElementNS, createTextNode)
import Web.DOM.Element (setAttribute, toEventTarget, toNode)
import Web.DOM.Node (appendChild, firstChild, insertBefore, nextSibling, removeChild, setTextContent)
import Web.DOM.Text as Text
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

foreign import nodeEq :: Node -> Node -> Effect Boolean

type Component r = Hooks r Unit

-- | [Internal] Set prop to element.
setProp :: forall r. Element -> Prop -> Component r
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
addChildrenJelly :: Node -> Jelly (Array Node) -> Jelly Unit
addChildrenJelly parentNode nodesJelly = do
  nodes <- nodesJelly

  liftEffect do
    anchorNodeRef <- new =<< firstChild parentNode

    for_ nodes \node -> do
      anchorNode <- read anchorNodeRef

      case anchorNode of
        Nothing ->
          appendChild node parentNode
        Just anchor -> do
          isEq <- nodeEq anchor node
          if isEq then do
            next <- nextSibling anchor
            write next anchorNodeRef
          else insertBefore node anchor parentNode

    -- Remove all nodes after anchor node.
    whileJust do
      anchorNode <- read anchorNodeRef
      case anchorNode of
        Nothing -> pure Nothing
        Just anchor -> do
          removeChild anchor parentNode
          next <- nextSibling anchor
          write next anchorNodeRef
          pure $ Just unit

elBase :: forall r. Element -> Array Prop -> Component r -> Component r
elBase element props childrenComponent = do
  for_ props $ setProp element

  { context } <- ask
  { nodesJelly, unmountEffect } <- liftEffect $ runHooks context
    childrenComponent
  useUnmountJelly $ liftEffect unmountEffect
  useJelly $ addChildrenJelly (toNode element) nodesJelly

  useNodeJelly $ pure $ toNode element

-- | Create element
el :: forall r. String -> Array Prop -> Component r -> Component r
el tagName props childrenComponent = do
  element <- liftEffect $ createElement tagName <<< toDocument =<< document =<<
    window

  elBase element props childrenComponent

elNS
  :: forall r
   . String
  -> String
  -> Array Prop
  -> Component r
  -> Component r
elNS ns tagName props childrenComponent = do
  element <- liftEffect $ createElementNS (Just ns) tagName <<< toDocument
    =<< document
    =<<
      window

  elBase element props childrenComponent

-- -- | Create element without props
el_ :: forall r. String -> Component r -> Component r
el_ tagName = el tagName []

elNS_ :: forall r. String -> String -> Component r -> Component r
elNS_ ns tagName = elNS ns tagName []

-- -- | Create empty element (== text $ pure "")
elEmpty :: forall r. Component r
elEmpty = pure unit

elIf :: forall r. Jelly Boolean -> Component r -> Component r -> Component r
elIf conditionJelly firstComponent secondComponent = do
  unmountEffectRef <- liftEffect $ new Nothing

  useUnmountJelly $ liftEffect do
    unmountEffect <- read unmountEffectRef
    case unmountEffect of
      Just x -> x
      Nothing -> pure unit

  { context } <- ask

  useNodesJelly do
    unmountEffectPrev <- liftEffect $ read unmountEffectRef
    case unmountEffectPrev of
      Just x -> liftEffect x
      Nothing -> pure unit

    condition <- conditionJelly
    { nodesJelly, unmountEffect } <- liftEffect $ runHooks context
      if condition then
        firstComponent
      else
        secondComponent

    liftEffect $ write (Just unmountEffect) unmountEffectRef

    nodesJelly

-- | Display components only when conditions are met
elWhen :: forall r. Jelly Boolean -> Component r -> Component r
elWhen conditionJelly childJelly = elIf conditionJelly childJelly elEmpty

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

  useNodeJelly $ pure node
