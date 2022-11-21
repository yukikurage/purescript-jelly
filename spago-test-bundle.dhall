let config = ./spago-test.dhall

in config //
  , backend = "purs-backend-es build"
  }
