module Jelly.LaunchApp where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Jelly.Data.Component (Component, runComponent)
import Web.DOM.Node (appendChild)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toNode)
import Web.HTML.Window (document)

launchApp :: forall r. Component r -> r -> Effect Unit
launchApp component context = do
  node /\ _ <- runComponent component context

  bm <- body =<< document =<< window

  case bm of
    Just b -> do
      appendChild node (toNode b)
    Nothing -> pure unit
