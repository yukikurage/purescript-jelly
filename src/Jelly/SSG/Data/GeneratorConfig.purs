module Jelly.SSG.Data.GeneratorConfig where

import Jelly.SSG.Data.Context

import Effect.Aff (Aff)
import Jelly.Core.Data.Component (Component)
import Jelly.Router.Data.Query (Query)

type GeneratorConfig context page =
  { basePath :: Array String
  , rootComponent :: Component context -> Component (SsgContext page ())
  , pageToUrl :: page -> { path :: Array String, query :: Query, hash :: String }
  , urlToPage :: { path :: Array String, query :: Query, hash :: String } -> page
  , pageComponent :: page -> String -> Component context
  , pageStaticData :: page -> Aff String
  , getPages :: Aff (Array page)
  , clientMain :: String
  , output :: Array String
  }
