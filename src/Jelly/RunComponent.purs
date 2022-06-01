module Jelly.RunComponent where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Jelly.Data.Hooks (runHooks)
import Jelly.Data.Jelly (alone)
import Jelly.HTML (Component)
import Web.DOM.Node (appendChild)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toNode)
import Web.HTML.Window (document)

-- | Run component with context
runComponent :: forall r. r -> Component r -> Effect Unit
runComponent r component = do
  bodyMaybe <- body =<< document =<< window

  node <- alone $ runHooks r component

  case bodyMaybe of
    Just b -> appendChild node (toNode b)
    Nothing -> pure unit
