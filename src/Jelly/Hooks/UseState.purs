module Jelly.Hooks.UseState where

import Prelude

import Control.Monad.Reader (ReaderT(..))
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Data.DependenciesSolver (connect, disconnectAll, getObserverCallback, getObserverEffect, getObservers, newObservedState, setObserverCallback)
import Jelly.Data.HookM (HookM)
import Jelly.Data.JellyM (JellyM(..))

type Modifier a = (a -> a) -> Effect Unit

useState
  :: forall m a
   . MonadEffect m
  => Eq a
  => a
  -> HookM m (JellyM a /\ Modifier a)
useState initValue = liftEffect do
  valueRef <- new initValue

  observedState <- newObservedState

  let
    getter = JellyM $ ReaderT \observer -> do
      case observer of
        Just obs -> connect obs observedState
        Nothing -> pure unit
      liftEffect $ read valueRef

    modifier f = do
      oldValue <- read valueRef
      let
        newValue = f oldValue
      if oldValue /= newValue then do
        observers <- getObservers observedState

        for_ observers \observer -> do
          disconnectAll observer
          fromMaybe (pure unit) =<< getObserverCallback observer

        write newValue valueRef

        for_ observers \observer -> do
          callback <- getObserverEffect observer
          setObserverCallback observer callback
      else pure unit

  pure $ getter /\ modifier
