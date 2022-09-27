module Jelly.Router.Data.Url where

import Prelude

import Effect (Effect)
import Jelly.Router.Data.Path (Path, dropBasePath, makeAbsoluteDirPath, stringToPath)
import Jelly.Router.Data.Query (Query, fromSearch, toSearch)
import Web.HTML (Location)
import Web.HTML.Location (hash, pathname, search)

type Url =
  { path :: Array String
  , query :: Query
  , hash :: String
  }

urlToString :: Path -> Url -> String
urlToString basePath { path, query, hash } =
  let
    pt = makeAbsoluteDirPath $ basePath <> path
    sr = case toSearch query of
      "" -> ""
      s -> "?" <> s
    hs = case hash of
      "" -> ""
      h -> "#" <> h
  in
    pt <> sr <> hs

locationToUrl :: Path -> Location -> Effect Url
locationToUrl basePath loc = do
  path <- dropBasePath basePath <<< stringToPath <$> pathname loc
  query <- fromSearch <$> search loc
  hash <- hash loc
  pure { path, query, hash }
