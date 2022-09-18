# 03 Hooks

Hooks are monads used to add logic to Component.

Hooks can execute an arbitrary Effect when the Component is mounted, and when it is unmounted.

Let's look at an example.

```purs
componentWithHooks :: Component Unit
componentWithHooks = makeComponent do
  -- This effect runs when the component is mounted
  liftEffect $ log "Mounted"

  -- This effect runs when the component is unmounted
  useUnmountEffect $ log "Unmounted"

  pure $ el_ "h1" do
    text $ pure "Hello, World!"
```

Here, the `makeComponent` function type is `makeComponent :: ∀ context. Hooks context (Component context) → Component context`.

Thus, what you write in `Hooks` directly with `liftEffect` will be executed on mount, and what you write in `useUnmountEffect` will be executed on unmount.
