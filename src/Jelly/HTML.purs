module Jelly.HTML where

import Prelude

import Control.Monad.Rec.Class (whileJust)
import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (new, read, write)
import Web.DOM (Element, Node)
import Web.DOM.Element (setAttribute)
import Web.DOM.Node (appendChild, firstChild, insertBefore, nextSibling, removeChild)

foreign import nodeEq :: Node -> Node -> Effect Boolean

-- newAttributeSignal :: Element -> String -> Signal String -> Effect (Signal Unit)
-- newAttributeSignal element attr signal = newSignal do
--   val <- readSignal signal
--   liftEffect $ setAttribute attr val element

-- newChildrenSignal :: Node -> Signal (Array Node) -> Effect (Signal Unit)
-- newChildrenSignal parentNode nodesSignal = newSignal $ do
--   nodes <- readSignal nodesSignal

--   liftEffect do
--     itrNodeRef <- new =<< firstChild parentNode

--     for_ nodes \node -> do
--       anchorNode <- read itrNodeRef

--       case anchorNode of
--         Nothing ->
--           appendChild node parentNode
--         Just anchor -> do
--           isEq <- nodeEq anchor node
--           if isEq then do
--             next <- nextSibling anchor
--             write next itrNodeRef
--           else insertBefore node anchor parentNode

--     -- Remove all nodes after anchor node.
--     whileJust do
--       anchorNode <- read itrNodeRef
--       case anchorNode of
--         Nothing -> pure $ Nothing
--         Just anchor -> do
--           next <- nextSibling anchor
--           removeChild anchor parentNode
--           write next itrNodeRef
--           pure $ Just unit
