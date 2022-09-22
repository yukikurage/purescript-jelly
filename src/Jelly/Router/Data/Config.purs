module Jelly.Router.Data.Config where

import Jelly.Router.Data.Url (Url)

type RouterConfig page =
  { basePath :: Array String
  , pageToUrl :: page -> Url
  , urlToPage :: Url -> page
  }
