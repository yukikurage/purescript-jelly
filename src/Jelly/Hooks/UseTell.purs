module Jelly.Hooks.UseTell where

import Prelude

import Control.Monad.Reader (ask)
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.HookM (HookM(..))
import Jelly.Data.Machine (tellMachine)

-- | Convert (m Unit) to (Effect Unit)
useTell
  :: forall m m'
   . MonadEffect m'
  => m Unit
  -> HookM m (m' Unit)
useTell listener = HookM do
  { machine } <- ask
  pure $ liftEffect $ tellMachine machine listener
