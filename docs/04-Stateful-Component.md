# 04 Stateful Component

Signal and Hooks can be combined to create a component with state.

## Counter

For example, let's create a counter

```purs
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
```

The text is a Signal String, and when the value of the Signal is changed, the component using that value is re-rendered.

## Timer

Next, we will try to make a timer, but we must be careful to stop the timer when unmounting.

```purs
timer :: Component Unit
timer = makeComponent do
  timeSig /\ timeAtom <- signal 0

  id <- liftEffect $ setInterval 1000 $ modifyAtom_ timeAtom (_ + 1)

  useUnmountEffect $ clearInterval id

  pure $ text $ show <$> timeSig
```
