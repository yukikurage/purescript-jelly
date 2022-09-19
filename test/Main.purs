module Test.Main where

import Prelude

import Effect (Effect)
import Jelly.SSG.Server (SsgSettings(..), ssg)
import Test.RootComponent (rootComponent)

ssgSettings :: SsgSettings
ssgSettings = SsgSettings
  { clientMain: "Test.EntryPoints.Browser"
  , output: "public"
  , component: rootComponent
  }

main :: Effect Unit
main = ssg ssgSettings
