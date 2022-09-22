module JellyExamples.Counter where

import Prelude

import Data.Tuple.Nested ((/\))
import Jelly.Core.Components (el, el_, text)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (makeComponent)
import Jelly.Core.Data.Prop (on)
import Jelly.Core.Data.Signal (modifyAtom_, signal)
import Web.HTML.Event.EventTypes (click)

counter :: Component ()
counter = makeComponent do
  countSig /\ countAtom <- signal 0

  pure $ el_ "div" do
    el "button" [ on click \_ -> modifyAtom_ countAtom (_ + 1) ] do
      text $ pure "Increment"
    el_ "div" do
      text $ show <$> countSig
