module Jelly.Util where

import Prelude

import Data.Array (drop, filter, foldMap, length)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), split)
import Effect (Effect)
import Web.HTML (Window)

makeAbsoluteFilePath :: Array String -> String
makeAbsoluteFilePath path = foldMap ("/" <> _) path

makeAbsoluteUrlPath :: Array String -> String
makeAbsoluteUrlPath path = makeAbsoluteFilePath path <> "/"

foreign import windowMaybeImpl :: (Window -> Maybe Window) -> Maybe Window -> Effect (Maybe Window)

windowMaybe :: Effect (Maybe Window)
windowMaybe = windowMaybeImpl Just Nothing

pathToArray :: String -> Array String
pathToArray path = filter (_ /= "") $ split (Pattern "/") path

dropBasePath :: Array String -> Array String -> Array String
dropBasePath basePath path = drop (length basePath) path
