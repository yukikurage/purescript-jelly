module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Jelly.RunApp (runApp)
import Test.AppTest (appTest)

main :: Effect Unit
main = launchAff_ $ runApp appTest
