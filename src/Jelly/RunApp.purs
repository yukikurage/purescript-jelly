module Jelly.RunApp where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Jelly.Data.HookM (HookM, runHookM)
import Web.DOM (Node)
import Web.DOM.Node (appendChild)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toNode)
import Web.HTML.Window (document)

runApp :: forall r. HookM r Node -> r -> Effect Unit
runApp hook r = do
  bodyMaybe <- body =<< document =<< window

  node /\ _ <- runHookM r hook

  case bodyMaybe of
    Just b -> appendChild node (toNode b)
    Nothing -> pure unit
