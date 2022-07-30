module Jelly.Hooks.UseDeferSignal where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.ST.Global (toEffect)
import Data.Array.ST (push)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal, detach)

useDeferSignal :: forall r. Signal Unit -> Hook r Unit
useDeferSignal defer = do
  { defersRef } <- ask
  liftEffect $ toEffect $ push (detach defer) defersRef $> unit
