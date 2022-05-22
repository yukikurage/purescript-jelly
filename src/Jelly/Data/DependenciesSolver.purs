module Jelly.Data.DependenciesSolver
  ( ObservedState
  , Observer
  , connect
  , disconnect
  , disconnectAll
  , getObserverCallback
  , getObserverEffect
  , getObservers
  , newObservedState
  , newObserver
  , setObserverCallback
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)

foreign import data Observer :: (Type -> Type) -> Type

foreign import data ObservedState :: (Type -> Type) -> Type

foreign import newObserverImpl
  :: forall m. (Observer m -> m (m Unit)) -> Effect (Observer m)

newObserver
  :: forall m. MonadEffect m => (Observer m -> m (m Unit)) -> m (Observer m)
newObserver f = liftEffect $ newObserverImpl f

foreign import newObservedStateImpl :: forall m. Effect (ObservedState m)

newObservedState :: forall m. MonadEffect m => m (ObservedState m)
newObservedState = liftEffect newObservedStateImpl

foreign import connectImpl
  :: forall m. Observer m -> ObservedState m -> Effect Unit

connect :: forall m. MonadEffect m => Observer m -> ObservedState m -> m Unit
connect o s = liftEffect $ connectImpl o s

foreign import disconnectImpl
  :: forall m. Observer m -> ObservedState m -> Effect Unit

disconnect :: forall m. MonadEffect m => Observer m -> ObservedState m -> m Unit
disconnect o s = liftEffect $ disconnectImpl o s

foreign import disconnectAllImpl
  :: forall m. Observer m -> Effect Unit

disconnectAll :: forall m. MonadEffect m => Observer m -> m Unit
disconnectAll o = liftEffect $ disconnectAllImpl o

foreign import setObserverCallbackImpl
  :: forall m. Observer m -> m Unit -> Effect Unit

setObserverCallback :: forall m. MonadEffect m => Observer m -> m Unit -> m Unit
setObserverCallback o cb = liftEffect $ setObserverCallbackImpl o cb

foreign import getObserverCallbackImpl
  :: forall m a
   . (a -> Maybe a)
  -> (Maybe a)
  -> Observer m
  -> Effect (Maybe (m Unit))

getObserverCallback
  :: forall m. MonadEffect m => Observer m -> m (Maybe (m Unit))
getObserverCallback o = liftEffect $ getObserverCallbackImpl Just Nothing o

foreign import getObserverEffect
  :: forall m. Observer m -> m (m Unit)

foreign import getObserversImpl
  :: forall m. ObservedState m -> Effect (Array (Observer m))

getObservers
  :: forall m. MonadEffect m => ObservedState m -> m (Array (Observer m))
getObservers s = liftEffect $ getObserversImpl s
