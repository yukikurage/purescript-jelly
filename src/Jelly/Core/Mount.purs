module Jelly.Core.Mount where

import Prelude

import Effect (Effect)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Hydrate (hydrate)
import Jelly.Core.Register (updateChildren)
import Web.DOM (Node)

mount
  :: forall context. Record context -> Component context -> Node -> Effect (Effect Unit)
mount ctx cmp node = do
  updateChildren node []
  hydrate ctx cmp node

mount_ :: forall context. Record context -> Component context -> Node -> Effect Unit
mount_ ctx cmp node = void $ mount ctx cmp node
