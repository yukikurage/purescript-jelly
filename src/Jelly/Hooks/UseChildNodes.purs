module Jelly.Hooks.UseChildNodes where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.ST.Global (toEffect)
import Data.Array.ST (push)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal)
import Web.DOM (Node)

useChildNodes :: forall r. Signal (Array Node) -> Hook r Unit
useChildNodes childNodes = do
  { childNodesRef } <- ask
  liftEffect $ toEffect $ push childNodes childNodesRef $> unit
