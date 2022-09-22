module Test.Context where

import Jelly.SSG.Data.Config (SsgContext)
import Test.Page (Page)

type Context :: Row Type
type Context = SsgContext Page ()
