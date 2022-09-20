module Jelly.RunJelly where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Component (Component)
import Jelly.Data.Emitter (emit, newEmitter)
import Jelly.Data.Instance (fromNode, updateChildren)
import Jelly.El (registerChildNodes)
import Web.DOM (Node)

runJelly :: Component () -> Node -> Effect (Effect Unit)
runJelly component node = do
  unmountEmitter <- newEmitter
  let
    inst = fromNode node

  liftEffect $ registerChildNodes true component {} unmountEmitter inst

  pure $ do
    emit unmountEmitter
    updateChildren [] inst

runJelly_ :: Component () -> Node -> Effect Unit
runJelly_ component node = void $ runJelly component node
