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
import Jelly.Data.Prop (on, (:=))
import Jelly.Data.Signal (Signal, modifyAtom_, readSignal, signal, writeAtom)
import Jelly.El (el, el_, embedNode, signalC, text)
import Jelly.Hooks.UseInterval (useInterval)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)
import Jelly.RunJelly (runJelly)
import Web.DOM (Element)
import Web.DOM.Document (createElement)
import Web.DOM.Element (toNode)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.Event.Event (target)
import Web.Event.Internal.Types (Event)
import Web.HTML (window)
import Web.HTML.Event.EventTypes (click, input)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.HTMLSelectElement as Select
import Web.HTML.Window (document)

type Context = Unit

foreign import setInnerHTML :: String -> Element -> Effect Unit

main :: Effect Unit
main = launchAff_ do
  elem <- awaitQuerySelector $ QuerySelector "#root"
  liftEffect $ traverse_ (runJelly rootComponent unit) elem

rootComponent :: Component Context
rootComponent = el_ "div" do
  el_ "h1" do
    text $ pure "🍮Hello, Jelly!"
  el_ "p" do
    text $ pure "This is a Jelly test."
  withTitle (pure "Timer") timer
  withTitle (pure "Counter") counter
  withTitle (pure "Embed") embed
  withTitle (pure "Mount / Unmount") mount

withTitle :: Signal String -> Component Context -> Component Context
withTitle titleSig component = el_ "div" do
  el_ "h2" $ text titleSig
  el "div" [ "style" := pure "padding: 10px" ] component

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

embed :: Component Context
embed = makeComponent do
  elem <- liftEffect $ createElement "div" <<< toDocument =<< document =<< window
  liftEffect $ setInnerHTML "<p>Hello from embedded component</p>" elem

  pure $ embedNode $ toNode elem

mount :: Component Context
mount = makeComponent do
  cmpNameSig /\ cmpNameAtom <- signal "timer"
  logTextSig /\ logTextAtom <- signal ""

  let
    addLog :: String -> Effect Unit
    addLog str = modifyAtom_ logTextAtom \logText ->
      logText <> str <> "\n"

    handleChange :: Event -> Effect Unit
    handleChange e = case Select.fromEventTarget =<< target e of
      Nothing -> pure unit
      Just select -> do
        v <- Select.value select
        addLog $ "input: " <> v
        writeAtom cmpNameAtom =<< Select.value select

    withMountMessage :: Signal String -> Component Context -> Component Context
    withMountMessage nameSig component = makeComponent do
      liftEffect do
        name <- readSignal nameSig
        addLog $ "mount: " <> name

      useUnmountEffect do
        name <- readSignal nameSig
        addLog $ "unmounted: " <> name

      pure component

  pure $ el_ "div" do
    el_ "div" do
      el "select" [ on input handleChange ] do
        el "option" [ "value" := pure "timer" ] do
          text $ pure "Timer"
        el "option" [ "value" := pure "counter" ] do
          text $ pure "Counter"
        el "option" [ "value" := pure "embed" ] do
          text $ pure "Embed"
    el "div" [ "style" := pure "border: 1px solid #ccc; padding: 10px; height: 50px;" ] do
      signalC do
        cmpName <- cmpNameSig
        pure $ case cmpName of
          "timer" -> withMountMessage (pure "Timer") timer
          "counter" -> withMountMessage (pure "Counter") counter
          "embed" -> withMountMessage (pure "Embed") embed
          _ -> mempty
    el_ "pre" do
      text logTextSig
