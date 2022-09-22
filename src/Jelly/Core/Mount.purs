module Jelly.Core.Mount where

import Prelude

import Effect (Effect)
import Jelly.Core.Components (registerChildComponent)
import Jelly.Core.Data.Component (Component, runComponent)
import Jelly.Core.Data.Instance (fromNode, updateChildren)
import Web.DOM (Node)

mount :: Component () -> Node -> Effect (Effect Unit)
mount component node = do
  let
    inst = fromNode node

  { unmountEffect } <- runComponent (registerChildComponent inst component) { context: {} }

  pure $ do
    unmountEffect
    updateChildren [] inst

mount_ :: Component () -> Node -> Effect Unit
mount_ component node = void $ mount component node
