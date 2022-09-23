module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console (log)
import Jelly.Core.Data.Signal (listen, new, writeAtom)

main :: Effect Unit
main = do
  signal1 /\ atom1 <- new 0
  signal2 /\ atom2 <- new 0
  let
    signal3 = add <$> signal1 <*> signal2

  unListen <- listen signal3 \x -> do
    log $ "signal3: " <> show x
    pure do
      log "signal3: done"

  writeAtom atom1 3
  writeAtom atom2 7

  unListen

  writeAtom atom1 3
  writeAtom atom2 4
