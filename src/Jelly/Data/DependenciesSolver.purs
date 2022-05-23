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

foreign import data Observer :: Type

foreign import data ObservedState :: Type

foreign import newObserver
  :: (Observer -> Effect (Effect Unit)) -> Effect Observer

foreign import newObservedState :: Effect ObservedState

foreign import connect
  :: Observer -> ObservedState -> Effect Unit

foreign import disconnect
  :: Observer -> ObservedState -> Effect Unit

foreign import disconnectAll
  :: Observer -> Effect Unit

foreign import setObserverCallback
  :: Observer -> Effect Unit -> Effect Unit

foreign import getObserverCallbackImpl
  :: forall a
   . (a -> Maybe a)
  -> (Maybe a)
  -> Observer
  -> Effect (Maybe (Effect Unit))

getObserverCallback
  :: Observer -> Effect (Maybe (Effect Unit))
getObserverCallback o = getObserverCallbackImpl Just Nothing o

foreign import getObserverEffect
  :: Observer -> Effect (Effect Unit)

foreign import getObservers
  :: ObservedState -> Effect (Array Observer)
