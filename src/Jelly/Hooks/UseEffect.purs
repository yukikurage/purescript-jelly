module Jelly.Hooks.UseEffect where

import Prelude

import Control.Monad.Reader (lift, runReaderT)
import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect)
import Jelly.Data.DependenciesSolver (disconnectAll, newObserver, setObserverCallback)
import Jelly.Data.HookM (HookM)
import Jelly.Data.JellyM (JellyM(..))
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

useEffect :: forall m. MonadEffect m => JellyM m (m Unit) -> HookM m Unit
useEffect (JellyM resolve) = do
  let
    func = runReaderT resolve
  observer <- lift $ newObserver \observer -> func $ Just observer

  callback <- lift $ func $ Just observer
  lift $ setObserverCallback observer callback

  useUnmountEffect $ lift $ disconnectAll observer
