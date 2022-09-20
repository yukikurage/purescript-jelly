module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Jelly.Generator (generate)
import Test.Chunk (Chunk(..))
import Test.Page (Page(..), toPath)
import Test.RootComponent (rootComponent)

main :: Effect Unit
main = launchAff_ do
  generate
    { pageToPath: toPath
    , pages: [ Hoge, Top ]
    , output: "public"
    , clientMain: "Test.ClientMain"
    , component: \page chunk -> rootComponent page chunk
    , chunks: [ Profile, Posts ]
    , chunkData: \chunk -> pure case chunk of
        Profile -> "profile"
        Posts -> "posts"
    }
