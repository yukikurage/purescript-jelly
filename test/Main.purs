module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console (log)
import Jelly.Data.Signal (alone, disconnectSignal, newSignal, readSignal)
import Jelly.Data.SignalRef (newSignalRef, writeSignalRef)

{-
numSignal --> signal1
booleanSignal --> signal1
stringSignal --> signal1 (when booleanSignal is true)
signal1 -> signal2

numSignal、または booleanSignal、そして booleanSignal が true のとき stringSignal が更新された場合、signal1 は更新される
signal1 の値が変わった時、signal2 が更新される

numSignal, booleanSignal, stringSignal, signal1 の値をメモしておく ↓
-}
main :: Effect Unit
main = do
  numSignal /\ numRef <- newSignalRef 0
  booleanSignal /\ booleanRef <- newSignalRef false
  stringSignal /\ stringRef <- newSignalRef "fuga"

  signal1 <- newSignal do
    log "signal1 called"

    num <- readSignal numSignal
    bool <- readSignal booleanSignal

    if bool then do
      str <- readSignal stringSignal
      pure $ show num <> " " <> str
    else do
      pure $ show num

  signal2 <- newSignal do
    log "signal2 called"

    _ <- readSignal signal1

    pure unit

  let
    logSignals = alone do
      num <- readSignal numSignal
      bool <- readSignal booleanSignal
      str <- readSignal stringSignal
      state1 <- readSignal signal1

      log $ show num <> " " <> show bool <> " " <> show str <> " " <> show
        state1

  -- 0, false, "fuga", "0"
  logSignals

  writeSignalRef numRef 1

  -- update: numSignal, signal1, signal2
  -- 1, false, "fuga", "1"
  logSignals

  writeSignalRef stringRef "hoge"

  -- update: stringRef
  -- 1, false, "hoge", "1"
  logSignals

  writeSignalRef booleanRef true

  -- update: booleanRef, signal1, signal2
  -- 1, true, "hoge", "1 hoge"
  logSignals

  writeSignalRef stringRef "fuga"

  -- update: stringRef, signal1, signal2
  -- 1, true, "fuga", "1 fuga"
  logSignals

  writeSignalRef booleanRef false

  -- update: booleanRef, signal1, signal2
  -- 1, false, "fuga", "1"
  logSignals

  writeSignalRef stringRef "hoge"

  -- update: stringRef
  -- 1, false, "hoge", "1"
  logSignals

  disconnectSignal signal2

  writeSignalRef numRef 3

  -- update: numRef, signal1
  -- 3, false, "hoge", "3"
  logSignals

  pure unit
