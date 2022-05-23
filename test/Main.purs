module Test.Main where

import Prelude

import Control.Monad.State (evalStateT)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Jelly.RunApp (runApp)
import Test.AppTest (appTest)

main :: Effect Unit
main = launchAff_ $ evalStateT (runApp appTest) 0
