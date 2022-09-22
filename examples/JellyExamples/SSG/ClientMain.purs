module JellyExamples.SSG.ClientMain where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Jelly.SSG.ClientMain (clientMain)
import JellyExamples.SSG.Config (ssgConfig)

main :: Effect Unit
main = launchAff_ $ clientMain ssgConfig
