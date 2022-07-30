module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console (log)
import Jelly.Data.Signal (launch_, pile, signal)

main :: Effect Unit
main = do
  sig0 /\ mod0 <- signal 0
  sig1 /\ mod1 <- signal "Hello"

  launch_ do
    num <- sig0
    log $ "num: " <> show num

    pile do
      str <- sig1
      log $ "stacked num: " <> show num
      log $ "stacked str: " <> str

  log "mod0 1"
  mod0 $ const 1

  log "mod1 World"
  mod1 $ const "World"

  log "mod0 2"
  mod0 $ const 2
