module Test.Context where

import Jelly.Data.Router (RouterContext)

type Context :: Row Type
type Context = RouterContext (Array String) ()
