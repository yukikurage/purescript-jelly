module Jelly.RunComponent where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Jelly.Data.Hooks (runHooks)
import Jelly.Data.Jelly (launchJelly_)
import Jelly.HTML (Component, addChildrenJelly)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toNode)
import Web.HTML.Window (document)

-- | Run component with context
runComponent :: forall r. r -> Component r -> Effect Unit
runComponent r component = do
  bodyMaybe <- body =<< document =<< window

  { nodesJelly } <- runHooks r component

  case bodyMaybe of
    Just b -> launchJelly_ $ addChildrenJelly (toNode b) nodesJelly
    Nothing -> pure unit
