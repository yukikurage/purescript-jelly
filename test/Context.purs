module Test.Context where

import Jelly.Router.Data.Router (RouterContext)
import Test.Page (Page)

type Context :: Row Type
type Context = RouterContext Page ()
