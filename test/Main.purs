module Test.Main where

import Prelude

import Data.Array (replicate)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console (log)
import Jelly.Data.Jelly (Jelly, addCleaner, alone, launchJelly, launchJelly_, newJelly, stopJelly)
import Jelly.Data.Props (on)
import Jelly.HTML (Component, el, el_, text, whenEl)
import Jelly.RunComponent (runComponent)

main :: Effect Unit
main = do
  log "Run App Test"
  runComponent appTest

  log "Child jelly cleaner test"
  childJellyCleanerTest

  log "Loop jelly test"
  loopJellyTest

  log "Test jelly"
  alone testJelly

appTest :: Component
appTest = do
  isShowCounter /\ modifyIsShowCounter <- newJelly false

  el_ "div"
    [ el "button"
        [ on "click" \_ -> modifyIsShowCounter not
        ]
        [ text $ ifM isShowCounter
            do pure "Stop"
            do pure "Run"
        ]
    , whenEl isShowCounter $ el_ "div" $ replicate 100 counter
    ]

testJelly :: Jelly Unit
testJelly = do
  state0 /\ modifyState0 <- newJelly 0
  state1 /\ modifyState1 <- newJelly 0

  launchJelly_ do
    x0 <- state0
    log $ "Rank 0, state0 == " <> show x0
    launchJelly_ do
      x1 <- state1
      log $ "Rank 1,  state0 == " <> show x0 <> ", state1 == " <> show x1
    pure unit

  log "modifyState1 (_ + 1)"
  modifyState1 (_ + 1)
  log "modifyState0 (_ + 10)"
  modifyState0 (_ + 10)
  log "modifyState1 (_ + 1)"
  modifyState1 (_ + 1)

counter :: Component
counter = do
  count /\ modifyCounterValue <- newJelly 0

  el_ "div"
    [ el "button"
        [ on "click" \_ -> modifyCounterValue (_ + 1)
        ]
        [ text $ pure "+" ]
    , el_ "div" [ text $ show <$> count ]
    , el "button"
        [ on "click" \_ -> modifyCounterValue (_ - 1)
        ]
        [ text $ pure "-" ]
    ]

childJellyCleanerTest :: Effect Unit
childJellyCleanerTest = alone $ do
  jellyId <- launchJelly do
    stateJelly /\ modifyState <- newJelly 0
    launchJelly_ do
      i <- stateJelly
      addCleaner do
        log $ "Child jelly cleaner called. State: " <> show i
    modifyState (_ + 1)
    modifyState (_ + 1)
    modifyState (_ + 1)
    modifyState (_ + 1)
    modifyState (_ + 1)
  stopJelly jellyId

loopJellyTest :: Effect Unit
loopJellyTest = alone $ do
  stateJelly /\ modifyState <- newJelly 0

  jellyId <- launchJelly do
    state <- stateJelly
    if state < 20 then do
      addCleaner $ log $ "First cleaner called. State: " <> show state
      log $ "Jelly called. State: " <> show state
      modifyState (_ + 1)
      addCleaner $ log $ "Second cleaner called. State: " <> show state
      log $ "Fin. State:" <> show state
    else pure unit

  log "Stopping jelly"
  stopJelly jellyId
