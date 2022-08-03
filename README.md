# Jelly

Jelly は非常に軽量な Web Application Framework です。

_Jelly is a very lightweight Web Application Framework._

仮想 DOM を用いていませんが、状態が更新された箇所のみを再描画できる仕組みを持っています。

_It does not use a virtual DOM, but has a mechanism that allows redrawing only where the state has been updated._

リアクティビティに似ていますが、とても簡単にされていて、逆に言うとそれほど抽象化はされていません。

_It is similar to reactivity, but made very simple and, conversely, not so abstract._

これは Web UI を組む際にそれほど抽象化は必要ないと判断したからです。

_This is because I decided that I don't need such abstraction when we build a Web UI._

## Installation

This package is not in package-sets, so add following to `packages.dhall`

```dhall
...
let upstream = ...
in  upstream
  with jelly =
    { dependencies =
     { dependencies =
      [ "arrays"
      , "effect"
      , "maybe"
      , "prelude"
      , "safely"
      , "st"
      , "tailrec"
      , "transformers"
      , "tuples"
      , "web-dom"
      , "web-events"
      , "web-html"
      ]
    , repo =
        "https://github.com/yukikurage/purescript-jelly"
    , version =
        "v0.3.0"
    }
...
```

and run `spago install jelly` (or `npx spago install jelly`)

## Example

See [Jelly Examples](https://yukikurage.github.io/purescript-jelly-examples/) and its [Repository](https://github.com/yukikurage/purescript-jelly-examples).
