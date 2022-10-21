{ name = "jelly"
, dependencies =
  [ "aff"
  , "arrays"
  , "console"
  , "effect"
  , "either"
  , "foreign"
  , "free"
  , "js-timers"
  , "maybe"
  , "newtype"
  , "prelude"
  , "refs"
  , "strings"
  , "tailrec"
  , "transformers"
  , "tuples"
  , "typelevel-prelude"
  , "unordered-collections"
  , "web-dom"
  , "web-events"
  , "web-html"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
, license = "MIT"
, repository = "https://github.com/yukikurage/purescript-jelly.git"
}
