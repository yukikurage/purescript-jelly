module Jelly.Hooks.Attr where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.ST.Global (toEffect)
import Data.Array.ST (push)
import Data.Tuple (Tuple(..))
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal)

attr :: forall r. String -> Signal String -> Hook r Unit
attr key strSig = do
  { attributesRef } <- ask
  liftEffect $ toEffect $ push (Tuple key strSig) attributesRef $> unit
