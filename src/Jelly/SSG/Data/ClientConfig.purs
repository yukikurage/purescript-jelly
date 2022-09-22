module Jelly.SSG.Data.ClientConfig where

import Jelly.Core.Data.Component (Component)
import Jelly.Router.Data.Query (Query)
import Jelly.SSG.Data.Context (SsgContext)

type ClientConfig context page =
  { basePath :: Array String
  , rootComponent :: Component context -> Component (SsgContext page ())
  , pageToUrl :: page -> { path :: Array String, query :: Query, hash :: String }
  , urlToPage :: { path :: Array String, query :: Query, hash :: String } -> page
  , pageComponent :: page -> String -> Component context
  }
