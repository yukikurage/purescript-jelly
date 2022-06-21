module Jelly.Data.JellyRef where

import Prelude

import Control.Monad.Reader (ask)
import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref as ERef
import Jelly.Data.Emitter (Emitter)
import Jelly.Data.Jelly (class MonadJelly, liftJelly)
import Jelly.Data.Jelly.Core (ObservedState, connect, disconnectAll, getObserverEffect, getObservers, newObservedState)

data JellyRef a = JellyRef (Emitter Effect Unit) (ERef.Ref a)

data JellyRefArray a = JellyRefArray (JellyRef (Array (JellyRef a)))

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

    ERef.write newValue ref

    for_ observers \observer -> do
      disconnectAll observer
      getObserverEffect observer

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
