module Jelly.Hooks.UseEffect where

import Prelude

import Control.Monad.Reader (runReaderT)
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Jelly.Data.DependenciesSolver (disconnectAll, newObserver, setObserverCallback)
import Jelly.Data.HookM (HookM)
import Jelly.Data.JellyM (JellyM(..), alone)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

useEffect :: forall r. JellyM (JellyM Unit) -> HookM r Unit
useEffect (JellyM resolve) = do
  let
    func = runReaderT resolve
  observer <- liftEffect $ newObserver \observer -> do
    callback <- func $ Just observer
    pure $ alone callback

  callback <- liftEffect $ func $ Just observer
  liftEffect $ setObserverCallback observer $ alone callback

  useUnmountEffect $ liftEffect $ disconnectAll observer
