let config = ./spago.dhall

in config //
  { sources = config.sources # [ "test/**/*.purs" ]
  , dependencies = config.dependencies # [ "console" ]
  , backend = "purs-backend-es build"
  }
