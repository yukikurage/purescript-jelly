module Jelly.Router.Data.Path where

import Prelude

import Data.Array (filter, foldMap)
import Data.String (Pattern(..), joinWith, split)

type Path = Array String

makeAbsoluteFilePath :: Path -> String
makeAbsoluteFilePath path = foldMap ("/" <> _) path

makeAbsoluteDirPath :: Path -> String
makeAbsoluteDirPath path = makeAbsoluteFilePath path <> "/"

makeRelativeFilePath :: Path -> String
makeRelativeFilePath path = joinWith "/" path

makeRelativeDirPath :: Path -> String
makeRelativeDirPath path = makeRelativeFilePath path <> "/"

stringToPath :: String -> Array String
stringToPath path = filter (_ /= "") $ split (Pattern "/") path
