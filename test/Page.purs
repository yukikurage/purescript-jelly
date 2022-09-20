module Test.Page where

import Prelude

import Data.Map (Map)
import Data.Map as Map

data Page = Hoge | Top | NotFound

derive instance Eq Page
instance Show Page where
  show = case _ of
    Hoge -> "Hoge"
    Top -> "Top"
    NotFound -> "NotFound"

toPath :: Page -> Array String
toPath = case _ of
  Hoge -> [ "hoge" ]
  Top -> []
  NotFound -> [ "404" ]

toUrl :: Page -> { path :: Array String, query :: Map String String, hash :: String }
toUrl page = { path: toPath page, query: Map.empty, hash: "" }

fromPath :: Array String -> Page
fromPath = case _ of
  [ "hoge" ] -> Hoge
  [] -> Top
  _ -> NotFound

fromUrl :: { path :: Array String, query :: Map String String, hash :: String } -> Page
fromUrl { path } = fromPath $ path

basePath :: Array String
basePath = []
