module Jelly.Data.Jelly.Core where

import Prelude

import Control.Safely (for_)
import Effect (Effect)

foreign import data Observer :: Type

foreign import data ObservedState :: Type

foreign import newObserver
  :: (Observer -> Effect Unit) -> Effect Observer

foreign import newObservedState :: Effect ObservedState

foreign import connect
  :: Observer -> ObservedState -> Effect Unit

foreign import disconnect
  :: Observer -> ObservedState -> Effect Unit

foreign import disconnectAll
  :: Observer -> Effect Unit

foreign import addObserverCallbacks
  :: Observer -> Effect Unit -> Effect Unit

foreign import clearObserverCallbacks :: Observer -> Effect Unit

foreign import getObserverCallbacks
  :: Observer
  -> Effect (Array (Effect Unit))

foreign import getObserverEffect
  :: Observer -> Effect Unit

foreign import getObservers
  :: ObservedState -> Effect (Array Observer)

runCallbackAndClear :: Observer -> Effect Unit
runCallbackAndClear observer = do
  callbacks <- getObserverCallbacks observer
  for_ callbacks \_ -> pure unit
  clearObserverCallbacks observer
