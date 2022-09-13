module Test.Main where

import Prelude

import Control.Safely (traverse_)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitQuerySelector)
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (makeComponent)
import Jelly.Data.Prop (on)
import Jelly.Data.Signal (Signal, modifyAtom_, signal)
import Jelly.El (el, el_, embed, text)
import Jelly.Hooks.UseInterval (useInterval)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.HTML.Event.EventTypes (click)

foreign import setBodyInnerHTML :: String -> Effect Unit

type Context = Unit

main :: Effect Unit
main = launchAff_ do
  elem <- awaitQuerySelector $ QuerySelector "#root"
  liftEffect $ traverse_ (embed rootComponent unit) elem

rootComponent :: Component Context
rootComponent = el_ "div" do
  el_ "h1" do
    text $ pure "Hello, Jelly!🍮"
  el_ "p" do
    text $ pure "This is a Jelly test."
  withTitle (pure "Timer") timer
  withTitle (pure "Counter") counter

withTitle :: Signal String -> Component Context -> Component Context
withTitle titleSig component = el "div" [] do
  el_ "h2" $ text titleSig
  component

timer :: Component Context
timer = makeComponent do
  timeSig /\ timeAtom <- signal 0

  useInterval 1000 $ modifyAtom_ timeAtom (_ + 1)

  pure $ text $ show <$> timeSig

counter :: Component Context
counter = makeComponent do
  countSig /\ countAtom <- signal 0

  pure $ el_ "div" do
    el "button" [ on click \_ -> modifyAtom_ countAtom (_ + 1) ] do
      text $ pure "Increment"
    text $ show <$> countSig
