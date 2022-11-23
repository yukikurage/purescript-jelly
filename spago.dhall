{ name = "jelly"
, dependencies =
  [ "aff"
  , "arrays"
  , "effect"
  , "either"
  , "free"
  , "jelly-hooks"
  , "jelly-signal"
  , "maybe"
  , "prelude"
  , "refs"
  , "safely"
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
