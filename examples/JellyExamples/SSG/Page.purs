module JellyExamples.SSG.Page where

import Prelude

import Data.Map as Map
import Jelly.Router.Data.Url (Url)

data Page = Top | About | NotFound

derive instance Eq Page

pageToUrl :: Page -> Url
pageToUrl page =
  let
    path = case page of
      Top -> []
      About -> [ "about" ]
      NotFound -> [ "404" ]
  in
    { path, hash: "", query: Map.empty }

urlToPage :: Url -> Page
urlToPage url =
  case url.path of
    [] -> Top
    [ "about" ] -> About
    _ -> NotFound

basePath :: Array String
basePath = []
