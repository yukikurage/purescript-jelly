module Jelly.RunApp where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.HookM (HookM, runHookM)
import Web.DOM (Node)
import Web.DOM.Node (appendChild)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toNode)
import Web.HTML.Window (document)

runApp :: forall m. MonadEffect m => HookM m Node -> m Unit
runApp hook = do
  bodyMaybe <- liftEffect $ body =<< document =<< window

  node /\ _ <- runHookM hook

  liftEffect case bodyMaybe of
    Just b -> appendChild node (toNode b)
    Nothing -> pure unit
