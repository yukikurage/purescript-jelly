module Test.Main where

import Prelude

import Control.Safely (traverse_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitQuerySelector)
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (makeComponent)
import Jelly.Data.Prop (on)
import Jelly.Data.Signal (Signal, modifyAtom_, signal, writeAtom)
import Jelly.El (el, el_, embed, signalC, text)
import Jelly.Hooks.UseInterval (useInterval)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.Event.Event (target)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes (change, click)
import Web.HTML.HTMLSelectElement as Select

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
  withTitle (pure "Mount / Unmount") mount

withTitle :: Signal String -> Component Context -> Component Context
withTitle titleSig component = el_ "div" do
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
    el_ "div" do
      text $ show <$> countSig

mount :: Component Context
mount = makeComponent do
  cmpNameSig /\ cmpNameAtom <- signal "timer"

  let
    handleChange :: Event -> Effect Unit
    handleChange e = case Select.fromEventTarget =<< target e of
      Nothing -> pure unit
      Just select -> writeAtom cmpNameAtom =<< Select.value select

  pure $ el_ "div" do
    el_ "div" do
      el "select" [ on change handleChange ] do
        el "option" [ on click \_ -> writeAtom cmpNameAtom "timer" ] do
          text $ pure "Timer"
        el "option" [ on click \_ -> writeAtom cmpNameAtom "counter" ] do
          text $ pure "Counter"
    signalC do
      cmpName <- cmpNameSig
      pure $ case cmpName of
        "timer" -> timer
        "counter" -> counter
        _ -> mempty
