module Jelly.HTML where

import Prelude

import Control.Monad.Reader (ask)
import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.Hooks (Hooks, runHooks)
import Jelly.Data.Jelly (Jelly, alone)
import Jelly.Data.Jelly.Class (liftJelly)
import Jelly.Data.Place (appendNodeToPlace, appendPlace, appendPlaceToNode, newPlace, removeNodeFromPlace)
import Jelly.Data.Props (Prop(..))
import Jelly.Hooks.UseJelly (useJelly)
import Jelly.Hooks.UseUnmountJelly (useUnmountJelly)
import Web.DOM (Element, Node)
import Web.DOM.Document (createElement, createElementNS, createTextNode)
import Web.DOM.Element (setAttribute, toEventTarget, toNode)
import Web.DOM.Node (setTextContent)
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
  { parentPlace } <- ask

  liftEffect $ appendNodeToPlace node parentPlace

  -- Add Unmount Effect
  useUnmountJelly $ liftEffect $ removeNodeFromPlace node parentPlace

elBase
  :: forall r
   . Element
  -> Array Prop
  -> Component r
  -> Component r
elBase element props childComponent = do
  -- Set Props
  for_ props $ setProp element

  { contexts } <- ask

  -- Add Node to Parent Node
  addNode $ toNode element

  place <- liftEffect newPlace

  liftEffect $ appendPlaceToNode place $ toNode element

  -- Add Children
  liftJelly $ runHooks
    { parentPlace: place, contexts }
    childComponent

-- | Create element
el :: forall r. String -> Array Prop -> Component r -> Component r
el tagName props childComponent = do
  -- Create Element
  element <- liftEffect $ createElement tagName <<< toDocument =<< document =<<
    window

  elBase element props childComponent

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

  elBase element props childComponent

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

emptyTextNode :: forall m. MonadEffect m => m Node
emptyTextNode = liftEffect $ Text.toNode <$>
  ( createTextNode "" <<< toDocument
      =<< document
      =<< window
  )

elIf :: forall r. Jelly Boolean -> Component r -> Component r -> Component r
elIf conditionJelly firstChildComponent secondChildComponent = do
  -- Copy without anchor node
  { parentPlace, contexts } <- ask

  place <- liftEffect newPlace

  liftEffect $ appendPlace place parentPlace

  let hooksInternal = { parentPlace: place, contexts }

  useJelly do
    -- Ref condition
    condition <- conditionJelly

    if condition then runHooks hooksInternal firstChildComponent
    else runHooks hooksInternal secondChildComponent

-- elFor
--   :: forall r a
--    . Jelly (Array a)
--   -> (a -> Maybe String)
--   -> (Jelly a -> Component r)
--   -> Component r
-- elFor arrJelly getKeyFunc getComponentFunc = do
--   -- Create Anchor Node, which will be used to insert element
--   anchorNode <- emptyTextNode

--   -- Add Anchor Node to parent Node
--   addNode anchorNode

--   -- Save Previous Nodes
--   prevComponentsObj <- liftEffect $ toEffect $ new

--   liftJelly do
--     -- when array updated
--     arr <- arrJelly

--     for_ arr \a -> do
--       let
--         keyMaybe = getKeyFunc a
--       prevComponentMaybe <- liftEffect $ case keyMaybe of
--         Nothing -> pure Nothing
--         Just key -> toEffect $ peek key prevComponentsObj

--       pure unit

--   pure unit

-- | Create text node
text :: forall r. Jelly String -> Component r
text txtJelly = do
  node <- emptyTextNode

  useJelly do
    txt <- txtJelly
    liftEffect $ setTextContent txt node
    pure unit

  addNode node
