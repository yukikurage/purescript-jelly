module JellyExamples.SSG.ClientMain where

import Prelude

import Effect (Effect)
import Jelly.SSG.Client (makeClientMain)
import JellyExamples.SSG.RootComponent (rootComponent)

main :: Effect Unit
main = makeClientMain rootComponent
