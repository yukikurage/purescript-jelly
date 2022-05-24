module Jelly.RunComponent where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Jelly.Data.Jelly (Jelly, alone)
import Web.DOM (Node)
import Web.DOM.Node (appendChild)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toNode)
import Web.HTML.Window (document)

runComponent :: Jelly Node -> Effect Unit
runComponent jellyNode = do
  bodyMaybe <- body =<< document =<< window

  node <- alone jellyNode

  case bodyMaybe of
    Just b -> appendChild node (toNode b)
    Nothing -> pure unit
