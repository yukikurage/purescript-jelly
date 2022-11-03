module Test.Main where

import Prelude

import Data.Foldable (traverse_)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Jelly.Aff (awaitBody)
import Jelly.Component (Component, raw, text, textSig, whenC)
import Jelly.Element as JE
import Jelly.Hydrate (mount)
import Jelly.Prop (on, onMount, (:=))
import Signal (modifyChannel, newState, writeChannel)
import Signal.Hooks (runHooks_, useCleaner, useInterval)
import Web.HTML.Event.EventTypes (click)

main :: Effect Unit
main = launchAff_ do
  bodyMaybe <- awaitBody
  liftEffect $ flip runHooks_ {} $ traverse_ (mount root) bodyMaybe

root :: Component ()
root = do
  testComp
  testCounter
  testEffect
  testRaw

testComp :: Component ()
testComp = JE.div [ "class" := "test" ] $ text "Hello World!"

testState :: Component ()
testState = do
  timeSig /\ timeChannel <- newState 0

  useInterval 1000 do
    modifyChannel timeChannel (_ + 1)

  JE.div' $ textSig $ show <$> timeSig

testCounter :: Component ()
testCounter = do
  countSig /\ countChannel <- newState 0
  JE.div' do
    JE.button [ on click \_ -> modifyChannel countChannel (_ + 1) ] $ text "Increment"
    JE.div' $ textSig $ show <$> countSig

testEffect :: Component ()
testEffect = do
  fragSig /\ fragChannel <- newState true

  JE.div' do
    JE.button [ on click \_ -> writeChannel fragChannel true ] $ text "Mount"
    JE.button [ on click \_ -> writeChannel fragChannel false ] $ text "Unmount"
    whenC fragSig do
      useCleaner $ log "Unmounted"
      log "Mounted"
      JE.div [ onMount \_ -> log "Mounted(in props)" ] $ text "Mounted Elem"

testRaw :: Component ()
testRaw = JE.div' do
  raw $ "<div>In Raw Element</div>"
