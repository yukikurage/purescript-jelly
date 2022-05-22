module Jelly.Hooks.UseState where

import Prelude

import Control.Monad.Reader (ReaderT(..), lift)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple.Nested (type (/\), (/\))
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Data.DependenciesSolver (connect, disconnectAll, getObserverCallback, getObserverEffect, getObservers, newObservedState, setObserverCallback)
import Jelly.Data.HookM (HookM)
import Jelly.Data.JellyM (JellyM(..))
import Jelly.Data.Modifier (Modifier)

useState
  :: forall m a
   . MonadEffect m
  => Eq a
  => a
  -> HookM m (JellyM m a /\ Modifier m a)
useState initValue = lift do
  valueRef <- liftEffect $ new initValue

  observedState <- newObservedState

  let
    getter = JellyM $ ReaderT \internal -> do
      case internal of
        Just observer -> connect observer observedState
        Nothing -> pure unit
      liftEffect $ read valueRef

    modifier f = lift do
      oldValue <- liftEffect $ read valueRef
      let
        newValue = f oldValue
      if oldValue /= newValue then do
        observers <- getObservers observedState

        for_ observers \observer -> do
          disconnectAll observer
          fromMaybe (pure unit) =<< getObserverCallback observer

        liftEffect $ write newValue valueRef

        for_ observers \observer -> do
          callback <- getObserverEffect observer
          setObserverCallback observer callback
      else pure unit

  pure $ getter /\ modifier
