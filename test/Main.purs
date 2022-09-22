module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Jelly.SSG.Generator (generate)
import Test.Config (generatorConfig)

main :: Effect Unit
main = launchAff_ $ generate generatorConfig
