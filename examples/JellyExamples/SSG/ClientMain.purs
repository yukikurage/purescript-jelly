module JellyExamples.SSG.ClientMain where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Core.Aff (awaitDocument)
import Jelly.Core.Mount (mount_)
import JellyExamples.SSG.RootComponent (rootComponent)

main :: Effect Unit
main = launchAff_ do
  node <- awaitDocument
  liftEffect $ mount_ rootComponent node
