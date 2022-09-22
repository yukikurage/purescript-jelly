module Test.Context where

import Jelly.SSG.Data.GeneratorConfig (SsgContext)
import Test.Page (Page)

type Context :: Row Type
type Context = SsgContext Page ()
