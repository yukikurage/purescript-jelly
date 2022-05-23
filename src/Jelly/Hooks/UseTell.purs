module Jelly.Hooks.UseTell where

import Prelude

import Control.Monad.Reader (ask)
import Effect (Effect)
import Jelly.Data.HookM (HookM(..))
import Jelly.Data.Machine (tellMachine)

-- | Convert (m Unit) to (Effect Unit)
useTell
  :: forall m
   . m Unit
  -> HookM m (Effect Unit)
useTell listener = HookM do
  { machine } <- ask
  pure $ tellMachine machine listener
