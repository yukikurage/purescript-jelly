module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.Component (Component, el, text)
import Jelly.Data.Signal (signal)
import Jelly.Hooks.Ch (ch)
import Jelly.Hooks.Prop (prop)
import Jelly.Hooks.UseUnmountSignal (useUnmountSignal)
import Jelly.LaunchApp (launchApp)

type Context = Unit

main :: Effect Unit
main = launchApp root unit

root :: Component Context
root = el "div" do
  prop "id" $ pure "root"

  ch $ text $ pure "Hello, Jelly"

  ch $ el "div" do
    prop "class" $ pure "test"

    ch $ text $ pure "This is Jelly test"

  ch $ el "div" do
    countSig /\ countMod <- signal 0

    intervalId <- liftEffect $ setInterval 1000 $ do
      log "Count up"
      countMod (_ + 1)

    useUnmountSignal $ liftEffect $ clearInterval intervalId

    ch $ text do
      count <- countSig
      pure $ "This is Counter: " <> show count
