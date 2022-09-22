module Jelly.Core.Mount where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (new, write)
import Jelly.Core.Data.Component (Component, runComponent)
import Jelly.Core.Data.Instance (firstChild, fromNode, updateChildren)
import Jelly.Core.Data.Signal (launch)
import Web.DOM (Node)

hydrate :: Component () -> Node -> Effect (Effect Unit)
hydrate component node = do
  let
    inst = fromNode node

  realInstanceRef <- new =<< firstChild inst

  { instancesSig, unmountEffect } <- runComponent component
    { context: {}, realInstanceRef }

  write Nothing realInstanceRef

  stop <- launch do
    instances <- instancesSig
    liftEffect $ updateChildren instances inst

  pure do
    stop
    unmountEffect
    updateChildren [] inst

hydrate_ :: Component () -> Node -> Effect Unit
hydrate_ component node = void $ hydrate component node

mount :: Component () -> Node -> Effect (Effect Unit)
mount component node = do
  let
    inst = fromNode node

  liftEffect $ updateChildren [] inst

  realInstanceRef <- new Nothing

  { instancesSig, unmountEffect } <- runComponent component
    { context: {}, realInstanceRef }

  write Nothing realInstanceRef

  stop <- launch do
    instances <- instancesSig
    liftEffect $ updateChildren instances inst

  pure do
    stop
    unmountEffect
    updateChildren [] inst

mount_ :: Component () -> Node -> Effect Unit
mount_ component node = void $ mount component node
