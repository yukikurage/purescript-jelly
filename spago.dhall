{ name = "jelly"
, dependencies =
  [ "aff"
  , "arrays"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "maybe"
  , "prelude"
  , "refs"
  , "jelly-hooks"
  , "jelly-signal"
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
