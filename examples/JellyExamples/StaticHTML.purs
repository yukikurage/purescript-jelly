module JellyExamples.HelloJelly where

import Prelude

import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitQuerySelector)
import Jelly.Data.Component (Component)
import Jelly.El (el_, text)
import Jelly.RunJelly (runJelly)
import Web.DOM.ParentNode (QuerySelector(..))

main :: Effect Unit
main = launchAff_ do
  appElemMaybe <- awaitQuerySelector $ QuerySelector "#app"
  liftEffect $ traverse_ (runJelly component) appElemMaybe

component :: Component ()
component = el_ "div" do
  el_ "h1" do
    text $ pure "Hello, Jelly!"
  el_ "p" do
    text $ pure "This is a Jelly example."
    el_ "div" do
      text $ pure "This is a nested element."
