module Jelly.Router.Data.Query where

import Prelude

import Data.Array (catMaybes)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), joinWith, split)
import Data.Tuple.Nested ((/\))

type Query = Map String String

fromSearch :: String -> Query
fromSearch sr = Map.fromFoldable
  $ catMaybes
  $ map
      ( \s -> case split (Pattern "=") s of
          [ k ] -> Just $ k /\ ""
          [ k, v ] -> Just $ k /\ v
          _ -> Nothing
      )
  $ split (Pattern "&")
  $ sr

toSearch :: Query -> String
toSearch q = joinWith "&"
  $ map
      (\(k /\ v) -> k <> "=" <> v)
  $ Map.toUnfoldable q
