module Test.Main where

import Prelude

import Effect (Effect)
import Jelly.Data.Component (Component, el, text)
import Jelly.Hooks.Ch (ch)
import Jelly.Hooks.Prop (prop)
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
