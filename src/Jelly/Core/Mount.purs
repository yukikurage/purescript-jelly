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

mount :: Boolean -> Component () -> Node -> Effect (Effect Unit)
mount isHydrate component node = do
  let
    inst = fromNode node

  liftEffect $ updateChildren [] inst

  realInstanceRef <- new =<< if isHydrate then firstChild inst else pure Nothing

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

hydrate :: Component () -> Node -> Effect (Effect Unit)
hydrate component node = mount true component node

hydrate_ :: Component () -> Node -> Effect Unit
hydrate_ component node = void $ hydrate component node

replace :: Component () -> Node -> Effect (Effect Unit)
replace component node = mount false component node

replace_ :: Component () -> Node -> Effect Unit
replace_ component node = void $ replace component node
