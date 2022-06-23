module Jelly.Data.Signal.Core where

import Prelude

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

foreign import getObserverEffect
  :: Observer -> Effect Unit

foreign import getObservers
  :: ObservedState -> Effect (Array Observer)
