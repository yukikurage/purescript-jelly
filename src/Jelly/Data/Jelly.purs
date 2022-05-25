module Jelly.Data.Jelly where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Data.Tuple (fst, snd)
import Data.Tuple.Nested (type (/\), (/\))
import Data.Unfoldable (replicateA)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Data.Jelly.Core (Observer, addObserverCallbacks, connect, disconnectAll, getObserverEffect, getObservers, newObservedState, newObserver, runCallbackAndClear)

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

newtype JellyId = JellyId (Effect Unit)

-- | Convert Jelly to Effect, dependencies are no longer tracked.
alone :: forall a. Jelly a -> Effect a
alone (Jelly m) = runReaderT m $ Nothing

-- | [Internal] Run a Jelly with a context and observer.
runJelly :: forall a. Observer -> Jelly a -> Effect a
runJelly observer (Jelly m) = runReaderT m $ Just observer

-- | Make new Jelly State.
newJelly
  :: forall m a
   . MonadEffect m
  => Eq a
  => a
  -> m (Jelly a /\ ((a -> a) -> Jelly Unit))
newJelly initValue = liftEffect do
  valueRef <- new initValue

  observedState <- newObservedState

  let
    getter = do
      observer <- ask
      liftEffect case observer of
        Just obs -> connect obs observedState
        Nothing -> pure unit
      liftEffect $ read valueRef

    modifier f = liftEffect do
      oldValue <- read valueRef
      let
        newValue = f oldValue
      if oldValue /= newValue then do
        observers <- getObservers observedState

        for_ observers \observer -> do
          disconnectAll observer
          runCallbackAndClear observer

        write newValue valueRef

        for_ observers \observer -> getObserverEffect observer
      else pure unit

  pure $ getter /\ modifier

-- | Make new Jelly States.
newJellies
  :: forall m a
   . MonadEffect m
  => Eq a
  => Int
  -> a
  -> m (Array (Jelly a) /\ Array ((a -> a) -> Jelly Unit))
newJellies n initValue = do
  res <- replicateA n (newJelly initValue)
  pure $ map fst res /\ map snd res

-- | Add Cleaner. This will be called when the Jelly is destroyed.
addCleaner :: Jelly Unit -> Jelly Unit
addCleaner cleaner = do
  observer <- ask
  let cleanerEffect = alone cleaner
  case observer of
    Just obs -> do
      liftEffect $ addObserverCallbacks obs cleanerEffect
    Nothing -> pure unit

-- | Launch a Jelly. Launched Jellyuns when dependant state changes.
launchJelly :: Jelly Unit -> Jelly JellyId
launchJelly jelly = do
  observer <- liftEffect $ newObserver \observer -> do
    runJelly observer jelly

  liftEffect $ runJelly observer jelly

  let
    stopJellyEffect = do
      disconnectAll observer
      runCallbackAndClear observer

  addCleaner $ liftEffect stopJellyEffect

  pure $ JellyId $ stopJellyEffect

-- | launchJelly without JellyId
launchJelly_ :: Jelly Unit -> Jelly Unit
launchJelly_ jelly = do
  observer <- liftEffect $ newObserver \observer -> do
    runJelly observer jelly

  liftEffect $ runJelly observer jelly

  let
    stopJellyEffect = do
      disconnectAll observer
      runCallbackAndClear observer

  addCleaner $ liftEffect stopJellyEffect

-- | stop Jelly
stopJelly :: forall m. MonadEffect m => JellyId -> m Unit
stopJelly (JellyId stop) = liftEffect stop
