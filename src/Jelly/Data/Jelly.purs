module Jelly.Data.Jelly where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref as ERef
import Jelly.Data.Jelly.Core (ObservedState, Observer, addObserverCallbacks, connect, disconnectAll, getObserverEffect, getObservers, newObservedState, newObserver, runCallbackAndClear)

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

data JellyRef a = JellyRef ObservedState (ERef.Ref a)

-- | Convert Jelly to Effect, dependencies are no longer tracked.
alone :: forall m a. MonadEffect m => Jelly a -> m a
alone (Jelly m) = liftEffect $ runReaderT m $ Nothing

-- | [Internal] Run a Jelly with a context and observer.
runJelly :: forall m a. MonadEffect m => Observer -> Jelly a -> m a
runJelly observer (Jelly m) = liftEffect $ runReaderT m $ Just observer

-- | Make new Jelly State.
new
  :: forall m a
   . MonadEffect m
  => a
  -> m (JellyRef a)
new initValue = liftEffect do
  observedState <- newObservedState

  valueRef <- ERef.new initValue

  pure $ JellyRef observedState valueRef

read :: forall m a. MonadJelly m => JellyRef a -> m a
read (JellyRef observedState valueRef) = liftJelly do
  observer <- ask
  liftEffect case observer of
    Just obs -> connect obs observedState
    Nothing -> pure unit
  liftEffect $ ERef.read valueRef

modifyWithEq
  :: forall m a
   . MonadEffect m
  => (a -> a -> Effect Boolean)
  -> JellyRef a
  -> (a -> a)
  -> m Unit
modifyWithEq eqFunc (JellyRef observedState ref) f = liftEffect do
  oldValue <- ERef.read ref
  let
    newValue = f oldValue

  whenM (not <$> eqFunc oldValue newValue) do
    observers <- getObservers observedState

    for_ observers \observer -> do
      disconnectAll observer
      runCallbackAndClear observer

    ERef.write newValue ref

    for_ observers \observer -> getObserverEffect observer

setWithEq
  :: forall m a
   . MonadEffect m
  => (a -> a -> Effect Boolean)
  -> JellyRef a
  -> a
  -> m Unit
setWithEq eqFunc jellyRef a = modifyWithEq eqFunc jellyRef
  (const a)

modify
  :: forall m a. MonadEffect m => Eq a => JellyRef a -> (a -> a) -> m Unit
modify jellyRef f = modifyWithEq (\x y -> pure $ eq x y)
  jellyRef
  f

set :: forall m a. MonadEffect m => Eq a => JellyRef a -> a -> m Unit
set jellyRef a = modify jellyRef (const a)

addCleaner :: forall m. MonadJelly m => Effect Unit -> m Unit
addCleaner cleaner = liftJelly do
  observer <- ask
  case observer of
    Just obs -> do
      liftEffect $ addObserverCallbacks obs cleaner
    Nothing -> pure unit

-- | Launch a Jelly. Launched Jelly runs when dependant state changes.

launchJelly :: forall m. MonadJelly m => Jelly Unit -> m JellyId
launchJelly jelly = liftJelly do
  observer <- liftEffect $ newObserver \observer -> do
    runJelly observer jelly

  runJelly observer jelly

  let
    stopJellyEffect = do
      disconnectAll observer
      runCallbackAndClear observer

  addCleaner $ liftEffect stopJellyEffect

  pure $ JellyId stopJellyEffect

-- | launchJelly without JellyId

launchJelly_ :: forall m. MonadJelly m => Jelly Unit -> m Unit
launchJelly_ jelly = liftJelly do
  observer <- liftEffect $ newObserver \observer -> do
    runJelly observer jelly

  runJelly observer jelly

  let
    stopJellyEffect = do
      disconnectAll observer
      runCallbackAndClear observer

  addCleaner $ liftEffect stopJellyEffect

-- | stop Jelly
stopJelly :: forall m. MonadEffect m => JellyId -> m Unit
stopJelly (JellyId stop) = liftEffect stop
