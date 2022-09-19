module Jelly.Util where

import Prelude

import Data.Array (fold)

makeAbsolutePath :: Array String -> String
makeAbsolutePath path = fold $ map ("/" <> _) path
