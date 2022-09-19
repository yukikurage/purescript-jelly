# 02 Signal and Atom

Signal and Atom is an important type for using Jelly.

Proper use of Signal can help manage reactive values.

## Create Signal and Atom

```purs
valSig /\ valAtom <- signal 0
pure unit
```

`signal` is a effective function that creates a Signal and Atom.

## Use Signal

```purs
launch_ do
  val <- valSig
  log $ show val
```

Since Signal is a Monad and MonadEffect, any effect can be embedded.

The `launch_` function is used to monitor Signal. Before describing the functions, Atom is explained.

## Use Atom

```purs
writeAtom valAtom 2
modifyAtom_ valAtom (_ + 3)
```

If Signal is the input, Atom is the output.

You can use `writeAtom`, `modifyAtom` or `modifyAtom_` to communicate value changes.

## Result

Continuing the above code in the main function, we get the following

```purs
import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console (log)
import Jelly.Data.Signal (launch_, modifyAtom_, signal, writeAtom)

main :: Effect Unit
main = do
  valSig /\ valAtom <- signal 0

  launch_ do
    val <- valSig
    log $ show val

  writeAtom valAtom 2
  modifyAtom_ valAtom (_ + 3)
```

```
0
2
5
```

The function of the `launch` function is as follows

- Detects value changes and re-executes the effect
- Automatic resolution of dependencies

The `signal` and `launch` functions can be used to manage reactive values.

## Stop launched Signal

In some cases, you may want to stop a Signal that was started with `launch_`.

In that case, use the `launch` function instead, which will return a function to stop it.

```purs
main = do
  valSig /\ valAtom <- signal 0
  stop <- launch do
    val <- valSig
    log $ show val
  writeAtom valAtom 2
  stop
  writeAtom valAtom 3
```

The above code will output the following

```
0
2
```
