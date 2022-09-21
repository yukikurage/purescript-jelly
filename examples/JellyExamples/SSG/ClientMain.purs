module JellyExamples.SSG.ClientMain where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitDocument)
import Jelly.Mount (mount_)
import JellyExamples.SSG.RootComponent (rootComponent)

main :: Effect Unit
main = launchAff_ do
  node <- awaitDocument
  liftEffect $ mount_ rootComponent node
