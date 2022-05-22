module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Milliseconds(..), delay, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Jelly.Data.HookM (runHookM)
import Jelly.RunApp (runApp)
import Test.AppTest (appTest)
import Test.DependenciesTest (dependenciesTest)

main :: Effect Unit
main = launchAff_ do
  {- Dependencies Test -}
  _ /\ unmount <- liftEffect $ runHookM dependenciesTest

  delay $ Milliseconds 1000.0

  log "setTimeout called"
  liftEffect $ unmount

  {- App Test -}

  liftEffect $ runApp appTest
