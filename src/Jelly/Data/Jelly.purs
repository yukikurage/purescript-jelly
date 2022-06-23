module Jelly.Data.Jelly where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.Jelly.Core (Observer, disconnectAll, newObserver)

class Monad m <= MonadJelly m where
  liftJelly :: forall a. Jelly a -> m a

type JellyInternal = Maybe Observer

newtype Jelly a = Jelly (ReaderT JellyInternal Effect a)

derive newtype instance Functor Jelly
derive newtype instance Apply Jelly
derive newtype instance Applicative Jelly
derive newtype instance Bind Jelly
derive newtype instance Monad Jelly
derive newtype instance MonadEffect Jelly
derive newtype instance MonadAsk JellyInternal Jelly
derive newtype instance MonadRec Jelly
instance MonadJelly Jelly where
  liftJelly = identity

newtype JellyId = JellyId (Effect Unit)

-- | Convert Jelly to Effect, dependencies are no longer tracked.
alone :: forall m a. MonadEffect m => Jelly a -> m a
alone (Jelly m) = liftEffect $ runReaderT m $ Nothing

-- | [Internal] Run a Jelly with a context and observer.
runJelly :: forall m a. MonadEffect m => Observer -> Jelly a -> m a
runJelly observer (Jelly m) = liftEffect $ runReaderT m $ Just observer

-- | Launch a Jelly. Launched Jelly runs when dependant state changes.
launchJelly :: forall m. MonadJelly m => Jelly Unit -> m JellyId
launchJelly jelly = liftJelly do
  observer <- liftEffect $ newObserver \observer -> do
    runJelly observer jelly

  runJelly observer jelly

  pure $ JellyId $ disconnectAll observer

-- | launchJelly without JellyId
launchJelly_ :: forall m. MonadJelly m => Jelly Unit -> m Unit
launchJelly_ jelly = liftJelly do
  observer <- liftEffect $ newObserver \observer -> do
    runJelly observer jelly

  runJelly observer jelly

-- | stop Jelly
stopJelly :: forall m. MonadEffect m => JellyId -> m Unit
stopJelly (JellyId stop) = liftEffect stop
