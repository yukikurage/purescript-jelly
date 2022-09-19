module Test.ClientMain where

import Prelude

import Effect (Effect)
import Jelly.SSG.Client (makeClientMain)
import Test.RootComponent (rootComponent)

main :: Effect Unit
main = makeClientMain rootComponent
