module Jelly.RunJelly where

import Prelude

import Effect (Effect)
import Jelly.Data.Component (Component)
import Jelly.Data.Emitter (newEmitter)
import Jelly.El (overwrite)
import Web.DOM (Element)

runJelly :: forall context. Component context -> context -> Element -> Effect Unit
runJelly component context element = do
  unmountEmitter <- newEmitter

  overwrite [] component context unmountEmitter element
