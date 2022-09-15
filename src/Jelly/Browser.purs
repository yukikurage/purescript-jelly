module Jelly.Browser where

import Prelude

import Effect (Effect)
import Jelly.Class.Platform (class Browser)
import Jelly.Data.Component (Component)
import Jelly.Data.Emitter (newEmitter)
import Jelly.El (overwrite)
import Web.DOM (Node)

runJelly :: forall context. Browser => Component context -> context -> Node -> Effect Unit
runJelly component context node = do
  unmountEmitter <- newEmitter
  overwrite component context unmountEmitter node
