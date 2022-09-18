module JellyExamples.Counter where

import Prelude

import Data.Tuple.Nested ((/\))
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (makeComponent)
import Jelly.Data.Prop (on)
import Jelly.Data.Signal (modifyAtom_, signal)
import Jelly.El (el, el_, text)
import Test.Context (Context)
import Web.HTML.Event.EventTypes (click)

counter :: Component Context
counter = makeComponent do
  countSig /\ countAtom <- signal 0

  pure $ el_ "div" do
    el "button" [ on click \_ -> modifyAtom_ countAtom (_ + 1) ] do
      text $ pure "Increment"
    el_ "div" do
      text $ show <$> countSig
