module Test.Main where

import Prelude

import Effect (Effect)
import Jelly.RunApp (runApp)
import Test.AppTest (appTest)

main :: Effect Unit
main = runApp appTest 0
