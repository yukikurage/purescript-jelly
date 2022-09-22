module Jelly.Core.Mount where

import Prelude

import Effect (Effect)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Instance (fromNode, updateChildren)
import Jelly.Core.Register (registerChildComponent)
import Web.DOM (Node)

hydrate :: Component () -> Node -> Effect (Effect Unit)
hydrate component node = registerChildComponent (fromNode node) component {}

hydrate_ :: Component () -> Node -> Effect Unit
hydrate_ component node = void $ hydrate component node

replace :: Component () -> Node -> Effect (Effect Unit)
replace component node = do
  updateChildren [] $ fromNode node
  hydrate component node

replace_ :: Component () -> Node -> Effect Unit
replace_ component node = void $ replace component node
