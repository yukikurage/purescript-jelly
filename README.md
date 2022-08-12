# Jelly

Jelly is a very lightweight Web Application Framework.

It does not use a virtual DOM, but has a mechanism that allows redrawing only where the state has been updated.

It is similar to reactivity, but made very simple and, conversely, not so abstract.

This is because I decided that I don't need such abstraction when we build a Web UI.

## Installation

This package is not in package-sets, so add following to `packages.dhall`

```dhall
...
let upstream = ...
in  upstream
  with jelly =
    { dependencies =
      [ "arrays"
      , "effect"
      , "foreign-object"
      , "js-timers"
      , "maybe"
      , "prelude"
      , "refs"
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
        "v0.4.1"
    }
...
```

and run `spago install jelly` (or `npx spago install jelly`)

## Example

See [Jelly Examples](https://yukikurage.github.io/purescript-jelly-examples/) and its [Repository](https://github.com/yukikurage/purescript-jelly-examples).
