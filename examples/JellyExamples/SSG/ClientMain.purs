module JellyExamples.SSG.ClientMain where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitDocument)
import Jelly.RunJelly (runJelly_)
import Test.RootComponent (rootComponent)

main :: Effect Unit
main = launchAff_ do
  node <- awaitDocument
  liftEffect $ runJelly_ rootComponent node
