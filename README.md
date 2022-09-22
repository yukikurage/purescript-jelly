# Jelly

Jelly is a framework with the following features

- No virtual DOM
- Declarative
- State management by reactivity (not FRP)
- Logic synthesis and reuse via Hooks
- Simple component separation
- SSG & SPA Routing support

See [docs directory](./docs) for more details.

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
      , "foldable-traversable"
      , "foreign"
      , "integers"
      , "js-timers"
      , "maybe"
      , "node-buffer"
      , "node-child-process"
      , "node-fs"
      , "node-fs-aff"
      , "node-path"
      , "node-streams"
      , "ordered-collections"
      , "parallel"
      , "posix-types"
      , "prelude"
      , "record"
      , "refs"
      , "safely"
      , "strings"
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

## Examples

See [Jelly Examples](https://yukikurage.github.io/purescript-jelly-examples/) and its [Repository](https://github.com/yukikurage/purescript-jelly-examples).
