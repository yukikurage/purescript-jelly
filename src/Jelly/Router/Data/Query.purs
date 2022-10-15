module Jelly.Router.Data.Query where

import Prelude

import Data.Array (catMaybes, filter)
import Data.HashMap (HashMap, fromFoldable, toArrayBy)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), joinWith, split)
import Data.Tuple.Nested ((/\))

type Query = HashMap String String

fromSearch :: String -> Query
fromSearch sr = fromFoldable
  $ catMaybes
  $ map
      ( \s -> case split (Pattern "=") s of
          [ k ] -> Just $ k /\ ""
          [ k, v ] -> Just $ k /\ v
          _ -> Nothing
      )
  $ filter (_ /= "")
  $ split (Pattern "&")
  $ sr

toSearch :: Query -> String
toSearch q = joinWith "&" $ toArrayBy (\k v -> k <> "=" <> v) q
