module Jelly.HTML where

import Prelude

import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Data.Jelly (Jelly, alone, launchJelly)
import Jelly.Data.Props (Prop(..))
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

setProp :: Element -> Prop -> Jelly Unit
setProp element prop = case prop of
  PropAttribute name valueJelly -> do
    _ <- launchJelly do
      value <- valueJelly
      liftEffect $ setAttribute name value element
    pure unit
  PropListener name listenerJelly -> do
    listener <- liftEffect $ eventListener \e -> alone $ listenerJelly e
    liftEffect $ addEventListener (EventType name) listener false $
      toEventTarget element

addChild :: Node -> Jelly Node -> Jelly Unit
addChild parentNode nodeJelly = do
  oldNodeRef <- liftEffect $ new Nothing

  _ <- launchJelly do
    oldNodeMaybe <- liftEffect $ read oldNodeRef
    newNode <- nodeJelly

    liftEffect case oldNodeMaybe of
      Nothing -> do
        appendChild newNode parentNode
      Just oldNode -> do
        insertBefore newNode oldNode parentNode
        removeChild oldNode parentNode
    liftEffect $ write (Just newNode) oldNodeRef

  pure unit

el
  :: String
  -> Array Prop
  -> Array (Jelly Node)
  -> Jelly Node
el tagName props children = do
  element <- liftEffect $ createElement tagName <<< toDocument =<< document =<<
    window
  for_ props $ setProp element
  for_ children $ addChild $ toNode element
  pure $ toNode element

div :: Array Prop -> Array (Jelly Node) -> Jelly Node
div = el "div"

button :: Array Prop -> Array (Jelly Node) -> Jelly Node
button = el "button"

text :: Jelly String -> Jelly Node
text txtJelly = do
  node <- liftEffect $ Text.toNode <$>
    ( createTextNode "" <<< toDocument
        =<< document
        =<< window
    )

  _ <- launchJelly do
    txt <- txtJelly
    liftEffect $ setTextContent txt node
    pure unit

  pure node
