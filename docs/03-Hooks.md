# 03 Hooks

Hooks are monads used to add logic to Component.

It can execute an arbitrary Effect when the Component is mounted, and when it is unmounted.

Let's look at an example.

```purs
import Prelude

import Effect.Class (liftEffect)
import Effect.Console (log)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (hooks)
import Jelly.Core.Components (el_, text)
import Jelly.Core.Hooks.UseUnmountEffect (useUnmountEffect)

componentWithHooks :: Component ()
componentWithHooks = hooks do
  -- This effect runs when the component is mounted
  liftEffect $ log "Mounted"

  -- This effect runs when the component is unmounted
  useUnmountEffect $ log "Unmounted"

  pure $ el_ "h1" do
    text $ pure "Hello, World!"
```

Here, the `hooks` function type is `hooks :: ∀ context. Hooks context (Component context) → Component context`.

Thus, what you write in `Hooks` directly with `liftEffect` will be executed on mount, and what you write in `useUnmountEffect` will be executed on unmount.
