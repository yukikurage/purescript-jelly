# 04 Stateful Component

Signal and Hooks can be combined to create a component with state.

## Counter

For example, let's create a counter

```purs
import Prelude

import Data.Tuple.Nested ((/\))
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (hooks)
import Jelly.Core.Data.Prop (on)
import Jelly.Core.Data.Signal (modifyAtom_, signal)
import Jelly.Core.Components (el, el_, text)
import Web.HTML.Event.EventTypes (click)

counter :: Component ()
counter = hooks do
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
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (hooks)
import Jelly.Core.Data.Signal (modifyAtom_, signal)
import Jelly.Core.Components (text)
import Jelly.Core.Hooks.UseUnmountEffect (useUnmountEffect)

timer :: Component ()
timer = hooks do
  timeSig /\ timeAtom <- signal 0

  id <- liftEffect $ setInterval 1000 $ modifyAtom_ timeAtom (_ + 1)

  useUnmountEffect $ clearInterval id

  pure $ text $ show <$> timeSig
```
