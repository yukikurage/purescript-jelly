module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console (log)
import Jelly.Data.Signal (launchSignal_, newSignal, stackSignal)

main :: Effect Unit
main = do
  sig0 /\ mod0 <- newSignal 0
  sig1 /\ mod1 <- newSignal "Hello"

  launchSignal_ do
    num <- sig0
    log $ "num: " <> show num

    stackSignal do
      str <- sig1
      log $ "stacked num: " <> show num
      log $ "stacked str: " <> str

  log "mod0 1"
  mod0 $ const 1

  log "mod1 World"
  mod1 $ const "World"
