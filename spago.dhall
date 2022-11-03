{ name = "jelly"
, dependencies =
  [ "aff"
  , "arrays"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "freet"
  , "maybe"
  , "prelude"
  , "refs"
  , "simple-hooks"
  , "simple-signal"
  , "tailrec"
  , "transformers"
  , "tuples"
  , "web-dom"
  , "web-events"
  , "web-html"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
, license = "MIT"
, repository = "https://github.com/yukikurage/purescript-jelly.git"
}
