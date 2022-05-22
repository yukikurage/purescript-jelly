module Jelly.Data.Emitter where

import Prelude

import Effect (Effect)

foreign import data EmitterListener :: (Type -> Type) -> Type -> Type
foreign import data Emitter :: (Type -> Type) -> Type -> Type

foreign import newEmitterListener
  :: forall m e. (e -> m Unit) -> Effect (EmitterListener m e)

foreign import newEmitter :: forall m e. Effect (Emitter m e)

foreign import addEmitterListener
  :: forall m e. Emitter m e -> EmitterListener m e -> Effect Unit

foreign import removeEmitterListener
  :: forall m e. Emitter m e -> EmitterListener m e -> Effect Unit

foreign import emit :: forall m e. Emitter m e -> e -> (Array (m Unit))

foreign import removeAllEmitterListeners
  :: forall m e. Emitter m e -> Effect Unit
