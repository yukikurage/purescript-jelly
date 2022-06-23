module Jelly.HTML where

import Prelude

-- import Control.Monad.Rec.Class (whileJust)
-- import Control.Safely (for_)
-- import Data.Array (concat)
-- import Data.Maybe (Maybe(..))
-- import Data.Traversable (for, sequence)
-- import Effect (Effect)
-- import Effect.Class (liftEffect)
-- import Effect.Ref (new, read, write)
-- import Jelly.Data.Hooks (Hooks, runHooks)
-- import Jelly.Data.Jelly (Jelly, alone, liftJelly, setWithEq)
-- import Jelly.Data.Jelly as J
-- import Jelly.Data.Props (Prop(..))
-- import Jelly.Hooks.UseContext (useContext)
-- import Jelly.Hooks.UseJelly (useJelly)
-- import Jelly.Hooks.UseState (useState)
-- import Web.DOM (Element, Node)
-- import Web.DOM.Document (createElement, createElementNS, createTextNode)
-- import Web.DOM.Element (setAttribute, toEventTarget, toNode)
-- import Web.DOM.Node (appendChild, firstChild, insertBefore, nextSibling, removeChild, setTextContent)
-- import Web.DOM.Text as Text
-- import Web.Event.Event (EventType(..))
-- import Web.Event.EventTarget (addEventListener, eventListener)
-- import Web.HTML (window)
-- import Web.HTML.HTMLDocument (toDocument)
-- import Web.HTML.Window (document)

-- foreign import nodeEq :: Node -> Node -> Effect Boolean

-- type Component r = Hooks r (Array Node)

-- -- | [Internal] Set prop to element.
-- setProp :: forall r. Element -> Prop -> Hooks r Unit
-- setProp element prop = do
--   case prop of
--     PropAttribute name valueJelly -> do
--       useJelly do
--         value <- valueJelly
--         liftEffect $ setAttribute name value element
--     PropListener name listenerJelly -> do
--       listener <-
--         liftEffect $ eventListener \e -> alone $ listenerJelly e

--       liftEffect $ addEventListener (EventType name) listener false $
--         toEventTarget element

-- mergeChildren
--   :: forall r. Array (Component r) -> Hooks r (Jelly (Array Node))
-- mergeChildren components = do
--   context <- useContext

--   nodesJellies :: Array (Jelly (Array Node)) <- for components \component -> do
--     nodesRef <- useState []
--     useJelly do
--       nodes <- runHooks context component
--       setWithEq (\_ _ -> pure false) nodesRef nodes
--       pure unit
--     pure $ J.read nodesRef

--   pure $ concat <$> sequence nodesJellies

-- updateChildren :: Node -> Array Node -> Effect Unit
-- updateChildren parentNode nodes = do
--   itrNodeRef <- new =<< firstChild parentNode

--   for_ nodes \node -> do
--     anchorNode <- read itrNodeRef

--     case anchorNode of
--       Nothing ->
--         appendChild node parentNode
--       Just anchor -> do
--         isEq <- nodeEq anchor node
--         if isEq then do
--           next <- nextSibling anchor
--           write next itrNodeRef
--         else insertBefore node anchor parentNode

--   -- Remove all nodes after anchor node.
--   whileJust do
--     anchorNode <- read itrNodeRef
--     case anchorNode of
--       Nothing -> pure $ Nothing
--       Just anchor -> do
--         next <- nextSibling anchor
--         removeChild anchor parentNode
--         write next itrNodeRef
--         pure $ Just unit

-- elBase :: forall r. Element -> Array Prop -> Array (Component r) -> Component r
-- elBase element props childrenComponents = do
--   for_ props $ setProp element

--   nodesJelly <- mergeChildren childrenComponents
--   useJelly do
--     nodes <- nodesJelly
--     liftEffect $ updateChildren (toNode element) nodes

--   pure [ toNode element ]

-- -- -- | Create element
-- el :: forall r. String -> Array Prop -> Array (Component r) -> Component r
-- el tagName props childrenComponent = do
--   element <- liftEffect $ createElement tagName <<< toDocument =<< document =<<
--     window

--   elBase element props childrenComponent

-- elNS
--   :: forall r
--    . String
--   -> String
--   -> Array Prop
--   -> Array (Component r)
--   -> Component r
-- elNS ns tagName props childrenComponent = do
--   element <- liftEffect $ createElementNS (Just ns) tagName <<< toDocument
--     =<< document
--     =<<
--       window

--   elBase element props childrenComponent

-- -- -- -- | Create element without props
-- el_ :: forall r. String -> Array (Component r) -> Component r
-- el_ tagName = el tagName []

-- elNS_ :: forall r. String -> String -> Array (Component r) -> Component r
-- elNS_ ns tagName = elNS ns tagName []

-- -- -- -- | Create empty element (== text $ pure "")
-- elEmpty :: forall r. Component r
-- elEmpty = pure []

-- elIf :: forall r. Jelly Boolean -> Component r -> Component r -> Component r
-- elIf conditionJelly firstComponent secondComponent = do
--   condition <- liftJelly conditionJelly
--   if condition then firstComponent else secondComponent

-- -- -- | Display components only when conditions are met
-- elWhen :: forall r. Jelly Boolean -> Component r -> Component r
-- elWhen conditionJelly childJelly = elIf conditionJelly childJelly elEmpty

-- -- elFor
-- --   :: forall r a
-- --    . Eq a
-- --   => Jelly (Array a)
-- --   -> (a -> Maybe String)
-- --   -> (Jelly a -> Component r)
-- --   -> Component r
-- -- elFor arrJelly getKey getComponent = do
-- --   { context } <- ask

-- --   -- | Save Previous node list and unmount Effect
-- --   -- | Ref (Object ({unmountEffect :: Effect Unit, nodesJelly :: J.Jelly (Array Node), dependentJellyRef :: J.JellyRef a}))
-- --   prevNodesObjRef <- liftEffect $ new $ empty

-- --   useJelly do
-- --     arr <- arrJelly

-- --     prevNodesObjST <- liftEffect $ toEffect <<< thawST =<< read prevNodesObjRef

-- --     -- Result
-- --     newNodesObjST <- liftEffect $ toEffect $ OST.new

-- --     newNodesST <- liftEffect $ toEffect $ AST.new

-- --     for_ arr \a -> do
-- --       let
-- --         keyMaybe = getKey a
-- --       prevNodesMaybe <- case keyMaybe of
-- --         Just key -> do
-- --           prevNodesMaybe <- liftEffect $ toEffect $ peek key prevNodesObjST
-- --           when (isJust prevNodesMaybe) $ liftEffect $ toEffect $
-- --             delete key prevNodesObjST *> pure unit
-- --           pure prevNodesMaybe
-- --         Nothing -> pure Nothing

-- --       { nodesJelly, unmountEffect, dependentJellyRef } <- case prevNodesMaybe of
-- --         Nothing -> do
-- --           dependentJellyRef <- J.new a
-- --           { nodesJelly, unmountEffect } <- liftEffect $ runHooks context
-- --             $ getComponent
-- --             $ J.read dependentJellyRef
-- --           pure { nodesJelly, unmountEffect, dependentJellyRef }
-- --         Just x -> pure x

-- --       nodes <- nodesJelly
-- --       _ <- liftEffect $ toEffect $ AST.pushAll nodes newNodesST

-- --       J.set dependentJellyRef a

-- --       case keyMaybe of
-- --         Just key -> liftEffect $ toEffect $
-- --           OST.poke key
-- --             { nodesJelly, unmountEffect, dependentJellyRef }
-- --             newNodesObjST *> pure unit
-- --         Nothing -> pure unit

-- --     -- Remove all nodes remained
-- --     prevNodesObj <- liftEffect $ toEffect $ freezeST prevNodesObjST
-- --     for_ prevNodesObj \{ unmountEffect } -> liftEffect unmountEffect

-- --     -- Replace old node Object
-- --     newNodeObj <- liftEffect $ toEffect $ freezeST newNodesObjST
-- --     liftEffect $ write newNodeObj prevNodesObjRef

-- --     liftEffect $ toEffect $ AST.freeze newNodesST

-- --   -- when unmount
-- --   useUnmountJelly do
-- --     prevNodesObj <- liftEffect $ read prevNodesObjRef
-- --     for_ prevNodesObj \{ unmountEffect } -> liftEffect unmountEffect

-- -- -- | Create text node
-- text :: forall r. Jelly String -> Component r
-- text txtJelly = do
--   node <- liftEffect $ Text.toNode <$>
--     ( createTextNode "" <<< toDocument
--         =<< document
--         =<< window
--     )

--   useJelly do
--     txt <- txtJelly
--     liftEffect $ setTextContent txt node
--     pure unit

--   pure [ node ]
