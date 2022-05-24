module Jelly.Data.Jelly where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT, ask, runReaderT)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Data.Jelly.Core (Observer, addObserverCallbacks, connect, disconnectAll, getObserverEffect, getObservers, newObservedState, newObserver, runCallbackAndClear)

type JellyInternal =
  { observer :: Maybe Observer
  }

newtype Jelly a = Jelly (ReaderT JellyInternal Effect a)

derive newtype instance Functor Jelly
derive newtype instance Apply Jelly
derive newtype instance Applicative Jelly
derive newtype instance Bind Jelly
derive newtype instance Monad Jelly
derive newtype instance MonadEffect Jelly
derive newtype instance MonadAsk JellyInternal Jelly

newtype JellyId = JellyId (Effect Unit)

alone :: forall a. Jelly a -> Effect a
alone (Jelly m) = runReaderT m { observer: Nothing }

runJelly :: forall a. Jelly a -> Observer -> Effect a
runJelly (Jelly m) observer = runReaderT m { observer: Just observer }

newJelly
  :: forall m m' a
   . MonadEffect m
  => MonadEffect m'
  => Eq a
  => a
  -> m (Jelly a /\ ((a -> a) -> m' Unit))
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

        for_ observers \observer -> do
          getObserverEffect observer
      else pure unit

  pure $ getter /\ modifier

addCleaner :: Jelly Unit -> Jelly Unit
addCleaner cleaner = do
  let cleanerEffect = alone cleaner
  { observer } <- ask
  case observer of
    Just obs -> do
      liftEffect $ addObserverCallbacks obs cleanerEffect
    Nothing -> pure unit

launchJelly :: Jelly Unit -> Jelly JellyId
launchJelly jelly = do
  observer <- liftEffect $ newObserver \observer -> do
    runJelly jelly observer

  liftEffect $ runJelly jelly observer

  let
    stopJellyEffect = do
      disconnectAll observer
      runCallbackAndClear observer

  addCleaner $ liftEffect stopJellyEffect

  pure $ JellyId $ stopJellyEffect

stopJelly :: forall m. MonadEffect m => JellyId -> m Unit
stopJelly (JellyId stop) = liftEffect stop