module JellyExamples.SSG.Main where

import Prelude

import Effect (Effect)
import Jelly.Generator (GeneratorSettings(..), generate)
import JellyExamples.SSG.RootComponent (rootComponent)

generatorSettings :: GeneratorSettings
generatorSettings = GeneratorSettings
  { clientMain: "Test.EntryPoints.Browser"
  , output: "public"
  , component: rootComponent
  }

main :: Effect Unit
main = generate generatorSettings
