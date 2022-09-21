module Jelly.Router.Data.Url where

import Prelude

import Data.Array (drop, filter, foldMap, length)
import Data.String (Pattern(..), split)
import Effect (Effect)
import Jelly.Router.Data.Query (Query, fromSearch, toSearch)
import Web.HTML (Location)
import Web.HTML.Location (hash, pathname, search)

type Url =
  { path :: Array String
  , query :: Query
  , hash :: String
  }

urlToString :: Array String -> Url -> String
urlToString basePath { path, query, hash } =
  let
    pt = makeAbsoluteUrlPath $ basePath <> path
    sr = case toSearch query of
      "" -> ""
      s -> "?" <> s
    hs = case hash of
      "" -> ""
      h -> "#" <> h
  in
    pt <> sr <> hs

locationToUrl :: Array String -> Location -> Effect Url
locationToUrl basePath loc = do
  path <- dropBasePath basePath <<< pathToArray <$> pathname loc
  query <- fromSearch <$> search loc
  hash <- hash loc
  pure { path, query, hash }

makeAbsoluteFilePath :: Array String -> String
makeAbsoluteFilePath path = foldMap ("/" <> _) path

makeAbsoluteUrlPath :: Array String -> String
makeAbsoluteUrlPath path = makeAbsoluteFilePath path <> "/"

pathToArray :: String -> Array String
pathToArray path = filter (_ /= "") $ split (Pattern "/") path

dropBasePath :: Array String -> Array String -> Array String
dropBasePath basePath path = drop (length basePath) path
