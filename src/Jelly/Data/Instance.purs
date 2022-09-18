module Jelly.Data.Instance where

import Prelude

import Effect (Effect)
import Jelly.Class.Platform (class Browser, class NodeJS)
import Web.DOM (Node)
import Web.Event.Event (EventType(..))
import Web.Event.Internal.Types (Event)

-- | Instance is a platform-dependent type generated from a Component.
-- | In the browser, type represent Element.
-- | In NodeJS, type represent mutable object.
-- | Operating Instance with reactivity is more efficient with a browser.
foreign import data Instance :: Type

foreign import newInstance :: String -> Effect Instance
foreign import newTextInstance :: String -> Effect Instance
foreign import newDocTypeInstance :: String -> String -> String -> Effect Instance
foreign import setAttribute :: String -> String -> Instance -> Effect Unit
foreign import removeAttribute :: String -> Instance -> Effect Unit
foreign import updateChildren :: Array Instance -> Instance -> Effect Unit
foreign import toHTMLImpl :: Instance -> Effect String
foreign import setInnerHTML :: String -> Instance -> Effect Unit

foreign import addEventListenerImpl
  :: String -> (Event -> Effect Unit) -> Instance -> Effect (Effect Unit)

foreign import setTextContent :: String -> Instance -> Effect Unit

foreign import toNodeImpl :: Instance -> Node

foreign import fromNodeImpl :: Node -> Instance

addEventListener :: EventType -> (Event -> Effect Unit) -> Instance -> Effect (Effect Unit)
addEventListener (EventType name) = addEventListenerImpl name

toNode :: Browser => Instance -> Node
toNode = toNodeImpl

fromNode :: Browser => Node -> Instance
fromNode = fromNodeImpl

toHTML :: NodeJS => Instance -> Effect String
toHTML = toHTMLImpl
