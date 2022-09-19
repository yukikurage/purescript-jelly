module Jelly.RunJelly where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (new)
import Jelly.Data.Component (Component, runComponent)
import Jelly.Data.Emitter (emit, newEmitter)
import Jelly.Data.Instance (fromNode, updateChildren)
import Jelly.El (registerChildNodes)
import Web.DOM (Node)
import Web.DOM.Node (firstChild)

runJelly :: Component () -> Node -> Effect (Effect Unit)
runJelly component node = do
  unmountEmitter <- newEmitter
  let
    inst = fromNode node

  realNodeRef <- liftEffect $ new =<< firstChild node

  childNodes <- liftEffect $ runComponent component { unmountEmitter, context: {}, realNodeRef }
  liftEffect $ registerChildNodes childNodes unmountEmitter inst

  pure $ do
    emit unmountEmitter
    updateChildren [] inst

runJelly_ :: Component () -> Node -> Effect Unit
runJelly_ component node = void $ runJelly component node
