module Jelly.Router.Data.Url where

import Prelude

import Effect (Effect)
import Jelly.Router.Data.Path (makeAbsoluteDirPath, stringToPath)
import Jelly.Router.Data.Query (Query, fromSearch, toSearch)
import Web.HTML (Location)
import Web.HTML.Location (hash, pathname, search)

type Url =
  { path :: Array String
  , query :: Query
  , hash :: String
  }

urlToString :: Url -> String
urlToString { path, query, hash } =
  let
    pt = makeAbsoluteDirPath $ path
    sr = case toSearch query of
      "" -> ""
      s -> "?" <> s
    hs = case hash of
      "" -> ""
      h -> "#" <> h
  in
    pt <> sr <> hs

locationToUrl :: Location -> Effect Url
locationToUrl loc = do
  path <- stringToPath <$> pathname loc
  query <- fromSearch <$> search loc
  hash <- hash loc
  pure { path, query, hash }
