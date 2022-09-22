module Jelly.SSG.Data.Context where

import Jelly.Router.Data.Router (RouterContext)
import Jelly.SSG.Data.StaticData (StaticDataContext)

type SsgContext page r = RouterContext page (StaticDataContext r)
