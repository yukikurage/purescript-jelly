# 04 Stateful Component

Signal and Hooks can be combined to create a component with state.

## Counter

For example, let's create a counter

```purs
import Prelude

import Data.Tuple.Nested ((/\))
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (makeComponent)
import Jelly.Data.Prop (on)
import Jelly.Data.Signal (modifyAtom_, signal)
import Jelly.El (el, el_, text)
import Web.HTML.Event.EventTypes (click)

counter :: Component ()
counter = makeComponent do
  countSig /\ countAtom <- signal 0

  pure $ el_ "div" do
    el "button" [ on click \_ -> modifyAtom_ countAtom (_ + 1) ] do
      text $ pure "Increment"
    el_ "div" do
      text $ show <$> countSig
```

## Timer

Next we will create a timer, but note that the timer should be stopped when unmounted.

```purs
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (makeComponent)
import Jelly.Data.Signal (modifyAtom_, signal)
import Jelly.El (text)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

timer :: Component ()
timer = makeComponent do
  timeSig /\ timeAtom <- signal 0

  id <- liftEffect $ setInterval 1000 $ modifyAtom_ timeAtom (_ + 1)

  useUnmountEffect $ clearInterval id

  pure $ text $ show <$> timeSig
```