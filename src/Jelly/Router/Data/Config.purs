module Jelly.Router.Data.Config where

import Jelly.Router.Data.Query (Query)

type RouterConfig page =
  { basePath :: Array String
  , pageToUrl ::
      page
      -> { path :: Array String
         , query :: Query
         , hash :: String
         }
  , urlToPage :: { path :: Array String, query :: Query, hash :: String } -> page
  }
