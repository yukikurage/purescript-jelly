module Jelly.RunApp where

import Prelude

import Control.Monad.Rec.Class (class MonadRec)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff.Class (class MonadAff)
import Effect.Class (liftEffect)
import Jelly.Data.HookM (HookM, runHookM)
import Jelly.Data.Machine (newMachine, runMachine)
import Web.DOM (Node)
import Web.DOM.Node (appendChild)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toNode)
import Web.HTML.Window (document)

runApp :: forall m. MonadAff m => MonadRec m => HookM m Node -> m Unit
runApp hook = do
  bodyMaybe <- liftEffect $ body =<< document =<< window

  machine <- liftEffect $ newMachine

  node /\ _ <- liftEffect $ runHookM machine hook

  liftEffect case bodyMaybe of
    Just b -> appendChild node (toNode b)
    Nothing -> pure unit

  runMachine machine
