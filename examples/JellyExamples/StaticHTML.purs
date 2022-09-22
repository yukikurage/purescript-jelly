module JellyExamples.HelloJelly where

import Prelude

import Control.Safely (traverse_)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Core.Aff (awaitQuerySelector)
import Jelly.Core.Components (el_, text)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Mount (mount_)
import Web.DOM.ParentNode (QuerySelector(..))

main :: Effect Unit
main = launchAff_ do
  appElemMaybe <- awaitQuerySelector $ QuerySelector "#app"
  liftEffect $ traverse_ (mount_ component) appElemMaybe

component :: Component ()
component = el_ "div" do
  el_ "h1" do
    text $ pure "Hello, Jelly!"
  el_ "p" do
    text $ pure "This is a Jelly example."
    el_ "div" do
      text $ pure "This is a nested element."
