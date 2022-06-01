module Jelly.Hooks.UseNodesJelly where

import Prelude

import Control.Monad.Reader (ask)
import Data.Array (singleton)
import Effect.Class (liftEffect)
import Effect.Ref (read, write)
import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Jelly (Jelly)
import Web.DOM (Node)

useNodesJelly :: forall r. Jelly (Array Node) -> Hooks r Unit
useNodesJelly newNodesJelly = do
  { nodesJellyRef } <- ask
  nodesJelly <- liftEffect $ read nodesJellyRef
  liftEffect $ write (append <$> nodesJelly <*> newNodesJelly) nodesJellyRef

useNodeJelly :: forall r. Jelly Node -> Hooks r Unit
useNodeJelly newNodeJelly = useNodesJelly (singleton <$> newNodeJelly)
