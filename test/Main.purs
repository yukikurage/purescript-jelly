module Test.Main where

import Prelude

import Data.Array (filter)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Jelly.Data.Component (Component, el, text)
import Jelly.Data.Signal (modifyAtom_, readSignal, signal)
import Jelly.Hooks.Ch (ch, chsFor)
import Jelly.Hooks.On (on)
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

  ch $ counter

  ch $ timer

  ch $ todoList

counter :: forall r. Component r
counter = el "div" do
  countSig /\ countAtom <- signal 0

  ch $ text do
    count <- countSig
    pure $ "Counter: " <> show count

  ch $ el "button" do
    on "click" \_ -> do
      modifyAtom_ countAtom (_ + 1)

    ch $ text $ pure "Increment"

timer :: forall r. Component r
timer = el "div" do
  countSig /\ countAtom <- signal 0

  useInterval 1000 $ modifyAtom_ countAtom $ (_ + 1)

  ch $ text do
    count <- countSig
    pure $ "Timer: " <> show count

initTasks
  :: Array
       { id :: String
       , title :: String
       }
initTasks =
  [ { id: "1", title: "Todo 1" }
  , { id: "2", title: "Todo 2" }
  , { id: "3", title: "Todo 3" }
  ]

todoList :: Component Context
todoList = el "div" do
  tasks /\ tasksAtom <- signal initTasks

  chsFor tasks (_.id >>> Just) \task -> el "div" do
    ch $ text $ _.title <$> task

    ch $ el "button" do
      "type" := pure "button"

      on "click" $ \_ -> do
        t <- readSignal task
        modifyAtom_ tasksAtom $ filter $ \t' -> t'.id /= t.id

      ch $ text $ pure "Delete"
