module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Jelly.Data.Component (Component, el, text)
import Jelly.Data.Signal (modifyAtom_, signal)
import Jelly.Hooks.Ch (ch)
import Jelly.Hooks.Prop ((:=))
import Jelly.Hooks.UseInterval (useInterval)
import Jelly.LaunchApp (launchApp)

type Context = Unit

main :: Effect Unit
main = launchApp root unit

root :: Component Context
root = el "div" do
  "id" := pure "root"

  ch $ text $ pure "Hello, Jelly! "

  ch $ text $ pure "This is Jelly test."

  ch $ el "div" do
    count /\ countAtom <- signal 0

    useInterval 1000 $ modifyAtom_ countAtom $ (_ + 1)

    ch $ text do
      c <- count
      pure $ "Count: " <> show c
