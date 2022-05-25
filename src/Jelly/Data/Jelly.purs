module Jelly.Data.Jelly where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested (type (/\), (/\))
import Data.Unfoldable (replicateA)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Data.Jelly.Core (Observer, addObserverCallbacks, connect, disconnectAll, getObserverEffect, getObservers, newObservedState, newObserver, runCallbackAndClear)

type JellyInternal r = { observer :: Maybe Observer, context :: r }

newtype Jelly r a = Jelly (ReaderT (JellyInternal r) Effect a)

derive newtype instance Functor (Jelly r)
derive newtype instance Apply (Jelly r)
derive newtype instance Applicative (Jelly r)
derive newtype instance Bind (Jelly r)
derive newtype instance Monad (Jelly r)
derive newtype instance MonadEffect (Jelly r)
derive newtype instance MonadAsk (JellyInternal r) (Jelly r)
derive newtype instance MonadRec (Jelly r)

newtype JellyId = JellyId (Effect Unit)

alone :: forall r a. r -> Jelly r a -> Effect a
alone context (Jelly m) = runReaderT m { observer: Nothing, context }

runJelly :: forall r a. Observer -> r -> Jelly r a -> Effect a
runJelly observer context (Jelly m) = runReaderT m $
  { observer: Just observer, context }

newJelly
  :: forall m r a
   . MonadEffect m
  => Eq a
  => a
  -> m (Jelly r a /\ ((a -> a) -> Jelly r Unit))
newJelly initValue = liftEffect do
  valueRef <- new initValue

  observedState <- newObservedState

  let
    getter = do
      { observer } <- ask
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

newJellies
  :: forall m r a
   . MonadEffect m
  => Eq a
  => Int
  -> a
  -> m (Array ((Jelly r a) /\ ((a -> a) -> Jelly r Unit)))
newJellies n initValue = replicateA n (newJelly initValue)

addCleaner :: forall r. Jelly r Unit -> Jelly r Unit
addCleaner cleaner = do
  { observer, context } <- ask
  let cleanerEffect = alone context cleaner
  case observer of
    Just obs -> do
      liftEffect $ addObserverCallbacks obs cleanerEffect
    Nothing -> pure unit

launchJelly :: forall r. Jelly r Unit -> Jelly r JellyId
launchJelly jelly = do
  { context } <- ask

  observer <- liftEffect $ newObserver \observer -> do
    runJelly observer context jelly

  liftEffect $ runJelly observer context jelly

  let
    stopJellyEffect = do
      disconnectAll observer
      runCallbackAndClear observer

  addCleaner $ liftEffect stopJellyEffect

  pure $ JellyId $ stopJellyEffect

launchJelly_ :: forall r. Jelly r Unit -> Jelly r Unit
launchJelly_ jelly = do
  { context } <- ask

  observer <- liftEffect $ newObserver \observer -> do
    runJelly observer context jelly

  liftEffect $ runJelly observer context jelly

  let
    stopJellyEffect = do
      disconnectAll observer
      runCallbackAndClear observer

  addCleaner $ liftEffect stopJellyEffect

stopJelly :: forall m. MonadEffect m => JellyId -> m Unit
stopJelly (JellyId stop) = liftEffect stop
