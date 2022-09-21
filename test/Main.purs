module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Jelly.Generator (generate)
import Test.Config (config)

main :: Effect Unit
main = launchAff_ $ generate config
