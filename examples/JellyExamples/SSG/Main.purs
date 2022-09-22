module JellyExamples.SSG.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Jelly.SSG.Generator (generate)
import JellyExamples.SSG.Config (ssgConfig)

main :: Effect Unit
main = launchAff_ $ generate ssgConfig
