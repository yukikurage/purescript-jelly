module Jelly.Data.Config where

import Effect.Aff (Aff)
import Jelly.Data.Component (Component)
import Jelly.Data.Query (Query)
import Jelly.Data.Router (RouterContext)

type Config context page =
  { basePath :: Array String
  , rootComponent :: Component context -> Component (RouterContext page ())
  , pageToUrl :: page -> { path :: Array String, query :: Query, hash :: String }
  , urlToPage :: { path :: Array String, query :: Query, hash :: String } -> page
  , pageComponent ::
      page
      -> { component :: String -> Component context
         , getStaticData :: Aff String
         }
  , getPages :: Aff (Array page)
  , clientMain :: String
  , output :: String
  }
