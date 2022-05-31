module Jelly.RunComponent where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Jelly.Data.Hooks (runHooks)
import Jelly.Data.Jelly (alone)
import Jelly.Data.Place (appendPlaceToNode, newPlace)
import Jelly.HTML (Component)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toNode)
import Web.HTML.Window (document)

-- | Run component with context
runComponent :: forall r. r -> Component r -> Effect Unit
runComponent contexts component = do
  bodyMaybe <- body =<< document =<< window

  place <- newPlace

  case bodyMaybe of
    Just b -> do
      appendPlaceToNode place $ toNode b
      alone $ runHooks { contexts, parentPlace: place } component
    Nothing -> pure unit
