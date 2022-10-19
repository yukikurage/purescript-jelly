module Jelly.Mount where

import Prelude

import Effect (Effect)
import Jelly.Data.Component (Component)
import Jelly.Hydrate (hydrate)
import Jelly.Register (updateChildren)
import Web.DOM (Node)

mount :: forall context. context -> Component context -> Node -> Effect (Effect Unit)
mount ctx cmp node = do
  updateChildren node []
  hydrate ctx cmp node

mount_ :: forall context. context -> Component context -> Node -> Effect Unit
mount_ ctx cmp node = void $ mount ctx cmp node
