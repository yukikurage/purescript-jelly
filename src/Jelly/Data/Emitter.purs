module Jelly.Data.Emitter where

import Prelude

import Effect (Effect)

foreign import data Emitter :: Type

foreign import newEmitter :: Effect Emitter
foreign import addListener :: Emitter -> Effect Unit -> Effect Unit
foreign import emit :: Emitter -> Effect Unit
