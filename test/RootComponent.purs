module Test.RootComponent where

import Prelude

import Data.Tuple.Nested ((/\))
import Jelly.Core.Components (docTypeHTML, el, el_, rawEl, text)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (hooks)
import Jelly.Core.Data.Prop (on, (:=))
import Jelly.Core.Data.Signal (Signal, modifyAtom_, signal)
import Jelly.Core.Hooks.UseInterval (useInterval)
import Jelly.Router.Data.Router (useRouter)
import Jelly.SSG.Components (link_, mainScript)
import Test.Context (Context)
import Test.Page (Page(..))
import Web.HTML.Event.EventTypes (click)

rootComponent :: Component Context -> Component Context
rootComponent pageComponent = do
  docTypeHTML
  el_ "html" do
    el_ "head" do
      mainScript
    el_ "body" do
      el_ "h1" do
        text $ pure "🍮Hello, Jelly!"
      el_ "p" do
        text $ pure "This is a Jelly test."
      withTitle (pure "Timer") timer
      withTitle (pure "Counter") counter
      withTitle (pure "Raw") raw
      withTitle (pure "Paging") paging
      withTitle (pure "Static") $ static pageComponent

withTitle :: Signal String -> Component Context -> Component Context
withTitle titleSig component = el_ "div" do
  el_ "h2" $ text titleSig
  el "div" [ "style" := "padding: 10px" ] component

timer :: Component Context
timer = hooks do
  timeSig /\ timeAtom <- signal 0

  useInterval 1000 $ modifyAtom_ timeAtom (_ + 1)

  pure $ text $ show <$> timeSig

counter :: Component Context
counter = hooks do
  countSig /\ countAtom <- signal 0

  pure $ el_ "div" do
    el "button" [ on click \_ -> modifyAtom_ countAtom (_ + 1) ] do
      text $ pure "Increment"
    el_ "div" do
      text $ show <$> countSig

raw :: Component Context
raw = rawEl "div" [] $ pure "<p>Raw HTML</p>"

paging :: Component Context
paging = hooks do
  { pageSig } <- useRouter

  pure do
    text $ pure "Paging with Router is available."

    el_ "div" do
      el_ "div" $ link_ Hoge do
        text $ pure "Hoge"
      el_ "div" $ link_ Top do
        text $ pure "Top"

    text $ ("Current page: " <> _) <<< show <$> pageSig

static :: Component Context -> Component Context
static pageComponent = hooks do

  pure $ el_ "div" do
    el_ "div" do
      text $ pure "Jelly can retrieve static data at build time and embed it in the page."
    el_ "div" do
      text $ pure "It is efficient because it can be stored in multiple chunks."
    pageComponent

topPage :: String -> Component Context
topPage dt = el_ "div" do
  text $ pure $ "Top: " <> dt

hogePage :: String -> Component Context
hogePage dt = el_ "div" do
  text $ pure $ "Posts: " <> dt

notFoundPage :: String -> Component Context
notFoundPage dt = el_ "div" do
  text $ pure $ "Not Found: " <> dt
