# Jelly

Jelly is a framework with the following features

- No virtual DOM
- Declarative
- State management by reactivity (not FRP)
- Logic synthesis and reuse via Hooks
- Simple component separation
- SSG & SPA Routing support

See [Jelly's home page](https://jelly.yukikurage.net/) for more details.

## Signal

Signal system is like [purescript-signal](https://github.com/bodil/purescript-signal), but can stop running signal.

## Installation

This package is not in package-sets, so add following to `packages.dhall`

```dhall
...
let upstream = ...
in  upstream
  with jelly =
    { dependencies =
      [ "aff"
      , "affjax"
      , "affjax-web"
      , "arrays"
      , "console"
      , "effect"
      , "either"
      , "foreign"
      , "foreign-object"
      , "free"
      , "js-timers"
      , "maybe"
      , "newtype"
      , "node-buffer"
      , "node-child-process"
      , "node-fs"
      , "node-fs-aff"
      , "node-streams"
      , "parallel"
      , "posix-types"
      , "prelude"
      , "record"
      , "refs"
      , "simple-json"
      , "strings"
      , "tailrec"
      , "transformers"
      , "tuples"
      , "web-dom"
      , "web-events"
      , "web-html"
      , "web-uievents"
      ]
    , repo =
        "https://github.com/yukikurage/purescript-jelly"
    , version =
        "v0.5.0"
    }
...
```

and run `spago install jelly` (or `npx spago install jelly`)

## Documents

See [docs directory](./docs) for more details.
