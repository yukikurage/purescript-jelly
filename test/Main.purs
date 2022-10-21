module Test.Main where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log, logShow)
import Jelly (Component, awaitBody, el, hooks, mount_, textSig, (:=))
import Jelly.Data.Signal (Signal, modifyAtom_, newState, newStateEq, runSignal, writeAtom)
import Jelly.Hooks (useInterval)

name :: Signal String
name = pure "Jelly"

helloEffect :: Signal (Effect (Effect Unit))
helloEffect = name <#> \s -> do
  log $ "Hello, " <> s <> "!"
  pure do
    log $ "Bye, " <> s <> "!"

main :: Effect Unit
main = do
  vSig /\ vAtom <- newStateEq false
  stop <- runSignal helloEffect
  stop

  cleanup <- runSignal $ vSig <#> \v -> do
    logShow v
    pure $ log $ "Cleanup:" <> show v

  writeAtom vAtom true
  writeAtom vAtom false
  writeAtom vAtom false
  writeAtom vAtom true
  cleanup
  writeAtom vAtom false
  writeAtom vAtom true

  launchAff_ do
    bodyMaybe <- awaitBody
    case bodyMaybe of
      Just body -> do
        liftEffect $ mount_ {} testComp body
      Nothing -> pure unit

testComp :: Component ()
testComp = el "div" [ "class" := "test" ] stateful

stateful :: Component ()
stateful = hooks do
  timeSig /\ timeAtom <- newState 0

  useInterval 1000 do
    modifyAtom_ timeAtom (_ + 1)

  pure $ textSig $ show <$> timeSig
