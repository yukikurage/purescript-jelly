module Jelly.Core.Data.Instance where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Web.DOM (Node)
import Web.Event.Event (EventType(..))
import Web.Event.Internal.Types (Event)

-- | Instance is a platform-dependent type generated from a Component.
-- | In the browser, type represent Node.
-- | In node.js, type represent mutable object.
foreign import data Instance :: Type

foreign import newInstance :: String -> Effect Instance
foreign import newTextInstance :: String -> Effect Instance
foreign import newDocTypeInstance :: String -> String -> String -> Effect Instance
foreign import setAttribute :: String -> String -> Instance -> Effect Unit
foreign import removeAttribute :: String -> Instance -> Effect Unit
foreign import updateChildren :: Array Instance -> Instance -> Effect Unit
foreign import toHTMLImpl :: Instance -> Effect String
foreign import setInnerHTML :: String -> Instance -> Effect Unit
foreign import firstChildImpl
  :: (Instance -> Maybe Instance) -> Maybe Instance -> Instance -> Effect (Maybe Instance)

foreign import addEventListenerImpl
  :: String -> (Event -> Effect Unit) -> Instance -> Effect (Effect Unit)

foreign import setTextContent :: String -> Instance -> Effect Unit
foreign import toNodeImpl :: Instance -> Node
foreign import fromNodeImpl :: Node -> Instance
foreign import nextSiblingImpl
  :: (Instance -> Maybe Instance) -> Maybe Instance -> Instance -> Effect (Maybe Instance)

addEventListener :: EventType -> (Event -> Effect Unit) -> Instance -> Effect (Effect Unit)
addEventListener (EventType name) = addEventListenerImpl name

-- | This function only works in the browser.
toNode :: Instance -> Node
toNode = toNodeImpl

-- | This function only works in the browser.
fromNode :: Node -> Instance
fromNode = fromNodeImpl

toHTML :: Instance -> Effect String
toHTML = toHTMLImpl

firstChild :: Instance -> Effect (Maybe Instance)
firstChild = firstChildImpl Just Nothing

nextSibling :: Instance -> Effect (Maybe Instance)
nextSibling = nextSiblingImpl Just Nothing
