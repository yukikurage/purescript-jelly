module Jelly.Hooks.UseListener where

import Prelude

import Control.Monad.Reader (ask)
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Jelly.Data.HookM (HookM(..))
import Jelly.Data.JellyM (JellyM, runAlone)
import Jelly.Data.Machine (listenerWithMachine)

-- | Convert (e -> JellyM m Unit) to (e -> Effect Unit)
-- | Dependencies will no longer be tracked
useListener
  :: forall e m
   . MonadEffect m
  => (e -> JellyM m Unit)
  -> HookM m (e -> Effect Unit)
useListener listener = HookM do
  { machine } <- ask
  pure $ listenerWithMachine machine $ \e -> runAlone $ listener e
