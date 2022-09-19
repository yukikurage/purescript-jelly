module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Jelly.Generator (generate)
import Test.Page (Page(..), toPath)
import Test.RootComponent (rootComponent)

main :: Effect Unit
main = launchAff_ do
  generate
    { pageToPath: toPath
    , pages: [ Hoge, Top ]
    , output: "public"
    , clientMain: "Test.ClientMain"
    , component: \page -> rootComponent page
    }
