module JellyExamples.Signal where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console (log)
import Jelly.Core.Data.Signal (launch_, modifyAtom_, signal, writeAtom)

main :: Effect Unit
main = do
  valSig /\ valAtom <- signal 0

  launch_ do
    val <- valSig
    log $ show val

  writeAtom valAtom 2
  modifyAtom_ valAtom (_ + 3)
