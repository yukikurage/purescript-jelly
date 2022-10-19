module Test.Main where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Jelly.Aff (awaitBody)
import Jelly.Data.Component (Component, el, textSig)
import Jelly.Data.Hooks (hooks)
import Jelly.Data.Prop ((:=))
import Jelly.Data.Signal (Signal, modifyAtom_, newState, runSignal)
import Jelly.Hooks.UseInterval (useInterval)
import Jelly.Mount (mount_)

name :: Signal String
name = pure "Jelly"

helloEffect :: Signal (Effect (Effect Unit))
helloEffect = name <#> \s -> do
  log $ "Hello, " <> s <> "!"
  pure do
    log $ "Bye, " <> s <> "!"

main :: Effect Unit
main = do
  stop <- runSignal helloEffect
  stop

  launchAff_ do
    bodyMaybe <- awaitBody
    case bodyMaybe of
      Just body -> do
        liftEffect $ mount_ unit testComp body
      Nothing -> pure unit

testComp :: Component Unit
testComp = el "div" [ "class" := "test" ] stateful

stateful :: Component Unit
stateful = hooks do
  timeSig /\ timeAtom <- newState 0

  useInterval 1000 do
    modifyAtom_ timeAtom (_ + 1)

  pure $ textSig $ show <$> timeSig
