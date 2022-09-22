module Test.RootComponent where

import Prelude

import Data.Array (snoc)
import Data.Tuple.Nested ((/\))
import Jelly.Core.Components (docTypeHTML, el, el_, rawEl, text)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (makeComponent)
import Jelly.Core.Data.Prop (on, (:=))
import Jelly.Core.Data.Signal (Signal, modifyAtom_, signal)
import Jelly.Core.Hooks.UseInterval (useInterval)
import Jelly.Router.Data.Router (useRouter)
import Jelly.Router.Data.Url (makeAbsoluteFilePath)
import Test.Context (Context)
import Test.Page (Page(..), basePath)
import Web.HTML.Event.EventTypes (click)

rootComponent :: Component Context -> Component Context
rootComponent pageComponent = makeComponent do

  pure do
    docTypeHTML
    el_ "html" do
      el_ "head" do
        el "script"
          [ "defer" := true
          , "type" := "text/javascript"
          , "src" := makeAbsoluteFilePath (basePath `snoc` "index.js")
          ]
          mempty
      el_ "body" do
        el_ "h1" do
          text $ pure "🍮Hello, Jelly!"
        el_ "p" do
          text $ pure "This is a Jelly test."
        withTitle (pure "Timer") timer
        withTitle (pure "Counter") counter
        -- withTitle (pure "Mount / Unmount") mount
        withTitle (pure "Raw") raw
        withTitle (pure "Paging") paging
        withTitle (pure "Static") $ static pageComponent

withTitle :: Signal String -> Component Context -> Component Context
withTitle titleSig component = el_ "div" do
  el_ "h2" $ text titleSig
  el "div" [ "style" := "padding: 10px" ] component

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

-- mount :: Component Context
-- mount = makeComponent do
--   cmpNameSig /\ cmpNameAtom <- signal "timer"
--   logTextSig /\ logTextAtom <- signal ""

--   let
--     addLog :: String -> Effect Unit
--     addLog str = modifyAtom_ logTextAtom \logText ->
--       logText <> str <> "\n"

--     handleChange :: Event -> Effect Unit
--     handleChange e = case Select.fromEventTarget =<< target e of
--       Nothing -> pure unit
--       Just select -> do
--         v <- Select.value select
--         addLog $ "input: " <> v
--         writeAtom cmpNameAtom =<< Select.value select

--     withMountMessage :: Signal String -> Component Context -> Component Context
--     withMountMessage nameSig component = makeComponent do
--       liftEffect do
--         name <- readSignal nameSig
--         addLog $ "mount: " <> name

--       useUnmountEffect do
--         name <- readSignal nameSig
--         addLog $ "unmounted: " <> name

--       pure component

-- pure $ el_ "div" do
--   el_ "div" do
--     el "select" [ on input handleChange ] do
--       el "option" [ "value" := "timer" ] do
--         text $ pure "Timer"
--       el "option" [ "value" := "counter" ] do
--         text $ pure "Counter"
--   el "div" [ "style" := "border: 1px solid #ccc;padding: 10px;height: 50px;" ] do
--     signalC do
--       cmpName <- cmpNameSig
--       pure $ case cmpName of
--         "timer" -> withMountMessage (pure "Timer") timer
--         "counter" -> withMountMessage (pure "Counter") counter
--         _ -> mempty
--   el_ "pre" do
--     text logTextSig

raw :: Component Context
raw = rawEl "div" [] $ pure "<p>Raw HTML</p>"

paging :: Component Context
paging = makeComponent do
  { pageSig, pushPage } <- useRouter

  pure do
    text $ pure "Paging with Router is available."

    el_ "div" do
      el "button" [ on click \_ -> pushPage Hoge ] do
        text $ pure "Hoge"
      el "button" [ on click \_ -> pushPage Top ] do
        text $ pure "Top"

    text $ ("Current page: " <> _) <<< show <$> pageSig

static :: Component Context -> Component Context
static pageComponent = makeComponent do

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
