module Test.Main where

import Prelude

import Data.Foldable (traverse_)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Jelly (Component, awaitBody, hooks, mount_, on, onMount, rawC, text, textSig, whenC, (:=))
import Jelly.Data.Signal (Signal, modifyAtom_, newState, writeAtom)
import Jelly.Element as JE
import Jelly.Hooks (useCleanup, useInterval)
import Web.HTML.Event.EventTypes (click)

name :: Signal String
name = pure "Jelly"

helloEffect :: Signal (Effect (Effect Unit))
helloEffect = name <#> \s -> do
  log $ "Hello, " <> s <> "!"
  pure do
    log $ "Bye, " <> s <> "!"

main :: Effect Unit
main = launchAff_ do
  bodyMaybe <- awaitBody
  liftEffect $ traverse_ (mount_ {} root) bodyMaybe

root :: Component ()
root = do
  testComp
  testCounter
  testEffect
  testRaw

testComp :: Component ()
testComp = JE.div [ "class" := "test" ] $ text "Hello World!"

testState :: Component ()
testState = hooks do
  timeSig /\ timeAtom <- newState 0

  useInterval 1000 do
    modifyAtom_ timeAtom (_ + 1)

  pure $ JE.div' $ textSig $ show <$> timeSig

testCounter :: Component ()
testCounter = hooks do
  countSig /\ countAtom <- newState 0
  pure $ JE.div' do
    JE.button [ on click \_ -> modifyAtom_ countAtom (_ + 1) ] $ text "Increment"
    JE.div' $ textSig $ show <$> countSig

testEffect :: Component ()
testEffect = hooks do
  fragSig /\ fragAtom <- newState true

  pure $ JE.div' do
    JE.button [ on click \_ -> writeAtom fragAtom true ] $ text "Mount"
    JE.button [ on click \_ -> writeAtom fragAtom false ] $ text "Unmount"
    whenC fragSig $ hooks do
      useCleanup $ log "Unmounted"
      log "Mounted"
      pure $ JE.div [ onMount \_ -> log "Mounted(in props)" ] $ text "Mounted Elem"

testRaw :: Component ()
testRaw = JE.div' do
  rawC $ "<div>In Raw Element</div>"