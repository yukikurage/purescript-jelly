module Test.ClientMain where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Jelly.ClientMain (clientMain)
import Test.Config (config)

main :: Effect Unit
main = launchAff_ $ clientMain config
