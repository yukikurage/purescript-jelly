module Jelly.Router.Data.Query where

import Prelude

import Data.Array (catMaybes)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), joinWith, split)
import Data.Tuple.Nested ((/\))
import Foreign.Object (Object, fromFoldable, toUnfoldable)

type Query = Object String

fromSearch :: String -> Query
fromSearch sr = fromFoldable
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
  $ toUnfoldable q
