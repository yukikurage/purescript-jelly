module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (launch_, signal)
import Jelly.HTML (el, txt)
import Jelly.Hooks.Attr (attr)
import Jelly.Hooks.UseDeferSignal (useDeferSignal)
import Jelly.LaunchApp (launchApp)

type Context = Unit

main :: Effect Unit
main = launchApp root unit

root :: Hook Context Unit
root = do
  txt $ pure "Hello, Jelly"

  el "div" do
    attr "class" $ pure "test"

    txt $ pure "This is Jelly test"

  el "div" do
    countSig /\ countMod <- signal 0

    intervalId <- liftEffect $ setInterval 1000 $ do
      log "Count up"
      countMod (_ + 1)

    useDeferSignal $ liftEffect $ clearInterval intervalId

    txt do
      count <- countSig
      pure $ "This is Counter: " <> show count
