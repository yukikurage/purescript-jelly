module Jelly.Data.Place where

import Prelude

import Control.Alternative (guard)
import Control.Monad.Rec.Class (whileJust)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Ref (new, read, write)
import Web.DOM (Node)
import Web.DOM.Document (createDocumentFragment, createTextNode)
import Web.DOM.DocumentFragment (toNode)
import Web.DOM.Node (appendChild, insertBefore, nextSibling, parentNode, removeChild)
import Web.DOM.Text as Text
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

foreign import nodeEq :: Node -> Node -> Effect Boolean

type Place =
  { startNode :: Node
  , endNode :: Node
  }

emptyTextNode :: Effect Node
emptyTextNode = Text.toNode <$>
  ( createTextNode "" <<< toDocument
      =<< document
      =<< window
  )

newPlace :: Effect Place
newPlace = do
  startNode <- emptyTextNode
  endNode <- emptyTextNode

  parentNode <- toNode <$>
    ( createDocumentFragment
        <<< toDocument
        =<< document
        =<< window
    )

  appendChild startNode parentNode
  appendChild endNode parentNode

  pure
    { startNode
    , endNode
    }

forEachNode :: Place -> (Node -> Effect Unit) -> Effect Unit
forEachNode { startNode, endNode } f = do
  itrRef <- new startNode
  whileJust do
    itr <- read itrRef
    nextNodeMaybe <- nextSibling itr

    f itr

    case nextNodeMaybe of
      Just nextNode -> do
        write nextNode itrRef
        guard <<< not <$> nodeEq itr endNode
      Nothing -> pure Nothing

appendPlaceToNode :: Place -> Node -> Effect Unit
appendPlaceToNode place parentNode = forEachNode place \node -> appendChild node
  parentNode

appendNodeToPlace :: Node -> Place -> Effect Unit
appendNodeToPlace node { endNode } = do
  parentNodeMaybe <- parentNode endNode

  case parentNodeMaybe of
    Just parentNode -> do
      insertBefore node endNode parentNode
    Nothing -> pure unit

insertPlaceBeforeNode :: Place -> Node -> Effect Unit
insertPlaceBeforeNode place anchorNode = do
  parentNodeMaybe <- parentNode anchorNode

  case parentNodeMaybe of
    Just parentNode -> forEachNode place \node -> insertBefore node anchorNode
      parentNode
    Nothing -> pure unit

appendPlace :: Place -> Place -> Effect Unit
appendPlace childPlace { endNode } = do
  insertPlaceBeforeNode childPlace endNode

insertPlaceBefore :: Place -> Place -> Effect Unit
insertPlaceBefore childPlace { startNode } = do
  insertPlaceBeforeNode childPlace startNode

removeNodeFromPlace :: Node -> Place -> Effect Unit
removeNodeFromPlace node { startNode } = do
  parentNodeMaybe <- parentNode startNode

  case parentNodeMaybe of
    Just parentNode -> do
      removeChild node parentNode
    Nothing -> pure unit

removePlace :: Place -> Effect Unit
removePlace place = do
  parentNodeMaybe <- parentNode place.startNode

  case parentNodeMaybe of
    Just parentNode -> forEachNode place \node -> removeChild node parentNode
    Nothing -> pure unit
