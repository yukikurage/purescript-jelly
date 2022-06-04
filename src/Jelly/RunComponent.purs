module Jelly.RunComponent where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hooks (runHooks)
import Jelly.Data.Jelly (alone, launchJelly_)
import Jelly.HTML (Component, updateChildren)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toNode)
import Web.HTML.Window (document)

-- | Run component with context
runComponent :: forall r. r -> Component r -> Effect Unit
runComponent r component = do
  bodyMaybe <- body =<< document =<< window

  let nodesJelly = runHooks r component

  case bodyMaybe of
    Just b -> alone $ launchJelly_ do
      nodes <- nodesJelly
      liftEffect $ updateChildren (toNode b) nodes
    Nothing -> pure unit
