module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console (log)
import Jelly.Data.Jelly (addCleaner, alone, launchJelly, newJelly, stopJelly)
import Jelly.Data.Props (on)
import Jelly.HTML (el, el_, text)
import Jelly.RunApp (runApp)

main :: Effect Unit
main = do
  log "Run App Test"
  appTest

  log "Child jelly cleaner test"
  childJellyCleanerTest

  log "Loop jelly test"
  loopJellyTest

appTest :: Effect Unit
appTest = runApp do
  counterValue /\ modifyCounterValue <- newJelly 0

  isShowCounter /\ modifyIsShowCounter <- newJelly false

  el_ "div"
    [ el "button"
        [ on "click" \_ -> modifyIsShowCounter not
        ]
        [ text $ ifM isShowCounter (pure "Hide") $ pure "Show" ]
    , ifM isShowCounter
        ( el_ "div"
            [ el "button"
                [ on "click" \_ -> modifyCounterValue (_ + 1)
                ]
                [ text $ pure "+" ]
            , el_ "div" [ text $ show <$> counterValue ]
            , el "button"
                [ on "click" \_ -> modifyCounterValue (_ - 1)
                ]
                [ text $ pure "-" ]
            ]
        ) $ el_ "div" []
    ]

childJellyCleanerTest :: Effect Unit
childJellyCleanerTest = do
  jellyId <- alone $ launchJelly do
    stateJelly /\ modifyState <- newJelly 0
    _ <- launchJelly do
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
loopJellyTest = do
  stateJelly /\ modifyState <- newJelly 0
  jellyId <- alone $ launchJelly do
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
