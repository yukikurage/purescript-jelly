# Useful Hooks

The following Hooks are provided for convenience.

## UseInterval / UseTimeout

Hooks that stop the timer when unmounting.

```purs
timer :: Component Unit
timer = makeComponent do
  timeSig /\ timeAtom <- signal 0

  id <- liftEffect $ setInterval 1000 $ modifyAtom_ timeAtom (_ + 1)

  useUnmountEffect $ clearInterval id

  pure $ text $ show <$> timeSig

```

↓

```purs
timer :: Component Unit
timer = makeComponent do
  timeSig /\ timeAtom <- signal 0

  useInterval 1000 $ modifyAtom_ timeAtom (_ + 1)

  pure $ text $ show <$> timeSig
```

## UseSignal

Launches Signal, but stops when unmounted.

```purs
component :: Component Unit
component = do
  valSig /\ valAtom <- signal 0

  stop <- launch do
    val <- valSig
    liftEffect $ log $show val

  useUnmountEffect stop

  pure $ el_ "div" do
    el "button" [ on click \_ -> modifyAtom_ valAtom (_ + 1) ] do
      text $ pure "Increment"
    el_ "div" do
      text $ show <$> valSig
```

↓

```purs
component :: Component Unit
component = do
  valSig /\ valAtom <- signal 0

  useSignal valSig do
    val <- valSig
    liftEffect $ log $show val

  pure $ el_ "div" do
    el "button" [ on click \_ -> modifyAtom_ valAtom (_ + 1) ] do
      text $ pure "Increment"
    el_ "div" do
      text $ show <$> valSig
```

## UseMemo

If you have a Signal that contains heavy calculations, you may be able to reduce the amount of calculations by using `UseMemo`.

For example, suppose you have a heavy computation `heavy :: Int -> Int`.

When a Signal using a heavy calculation is used in multiple places, as shown below, the heavy calculation is performed multiple times.

```purs
heavyComponent = do
  valSig /\ valAtom <- signal 0

  let
    heavySignal = heavy <$> valSig

  pure $ el_ "div" do
    el "button" [ on click \_ -> modifyAtom_ valAtom (_ + 1) ] do
      text $ pure "Increment"
    el_ "div" do
      text $ show <$> heavySignal
    el_ "div" do
      text $ show <$> heavySignal
    el_ "div" do
      text $ show <$> heavySignal
```

As a solution, we can create a new Signal and updated through it.

```purs
heavyComponent = do
  valSig /\ valAtom <- signal 0

  viaSig /\ viaAtom <- signal 0

  useSignal do
    val <- valSig
    writeAtom viaAtom $ heavy val

  pure $ el_ "div" do
    el "button" [ on click \_ -> modifyAtom_ valAtom (_ + 1) ] do
      text $ pure "Increment"
    el_ "div" do
      text $ show <$> viaSig
    el_ "div" do
      text $ show <$> viaSig
    el_ "div" do
      text $ show <$> viaSig
```

`useMemo` is a Hook to write this shortly.

```purs
heavyComponent = do
  valSig /\ valAtom <- signal 0

  viaSig <- useMemo $ heavy <$> valSig

  pure $ el_ "div" do
    el "button" [ on click \_ -> modifyAtom_ valAtom (_ + 1) ] do
      text $ pure "Increment"
    el_ "div" do
      text $ show <$> viaSig
    el_ "div" do
      text $ show <$> viaSig
    el_ "div" do
      text $ show <$> viaSig
```

## UseEventListener

Listens for Events, but stops when unmounted.
