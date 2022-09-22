module Jelly.SSG.Data.Config where

import Effect.Aff (Aff)
import Jelly.Core.Data.Component (Component)
import Jelly.Router.Data.Query (Query)
import Jelly.Router.Data.Router (RouterContext)

type SsgConfig context page =
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
