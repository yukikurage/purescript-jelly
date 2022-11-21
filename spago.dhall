{ name = "jelly"
, dependencies =
  [ "aff"
  , "arrays"
  , "effect"
  , "either"
  , "exists"
  , "foldable-traversable"
  , "free"
  , "jelly-hooks"
  , "jelly-signal"
  , "maybe"
  , "prelude"
  , "refs"
  , "tailrec"
  , "transformers"
  , "tuples"
  , "web-dom"
  , "web-events"
  , "web-html"
  ]
, packages = ./packages.dhall
, sources =
  [ "src/Jelly/Aff.purs"
  , "src/Jelly/Component.purs"
  , "src/Jelly/Element.purs"
  , "src/Jelly/Prop.purs"
  , "src/Jelly/Render.purs"
  ]
, license = "MIT"
, repository = "https://github.com/yukikurage/purescript-jelly.git"
}
