module Jelly.Data.Emitter where

import Prelude

import Data.Traversable (sequence_)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)

foreign import data RegistrationId :: Type
foreign import data Emitter :: (Type -> Type) -> Type -> Type

foreign import newEmitter :: forall m e. Effect (Emitter m e)

foreign import addEmitterListener
  :: forall m e. Emitter m e -> (e -> m Unit) -> Effect RegistrationId

foreign import addEmitterListenerOnce
  :: forall m e. Emitter m e -> (e -> m Unit) -> Effect RegistrationId

foreign import removeEmitterListener
  :: forall m e. Emitter m e -> RegistrationId -> Effect Unit

foreign import emitImpl
  :: forall m e. Emitter m e -> e -> Effect (Array (m Unit))

emit :: forall m e. MonadEffect m => Emitter m e -> e -> m Unit
emit emitter e = do
  arr <- liftEffect $ emitImpl emitter e
  sequence_ arr

foreign import removeAllEmitterListeners
  :: forall m e. Emitter m e -> Effect Unit
