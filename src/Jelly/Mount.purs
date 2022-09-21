module Jelly.Mount where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Component (Component)
import Jelly.Data.Emitter (emit, newEmitter)
import Jelly.Data.Instance (Instance, updateChildren)
import Jelly.El (registerChildNodes)

mount :: Component () -> Instance -> Effect (Effect Unit)
mount component inst = do
  unmountEmitter <- newEmitter

  liftEffect $ registerChildNodes true component {} unmountEmitter inst

  pure $ do
    emit unmountEmitter
    updateChildren [] inst

mount_ :: Component () -> Instance -> Effect Unit
mount_ component node = void $ mount component node
