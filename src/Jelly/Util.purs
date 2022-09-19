module Jelly.Util where

import Prelude

import Data.Array (drop, filter, foldMap, length)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), split)
import Effect (Effect)
import Web.HTML (Window)
import Web.HTML.Location (pathname)
import Web.HTML.Window (location)

makeAbsoluteFilePath :: Array String -> String
makeAbsoluteFilePath path = foldMap ("/" <> _) path

makeAbsoluteUrlPath :: Array String -> String
makeAbsoluteUrlPath path = makeAbsoluteFilePath path <> "/"

foreign import windowMaybeImpl :: (Window -> Maybe Window) -> Maybe Window -> Effect (Maybe Window)

windowMaybe :: Effect (Maybe Window)
windowMaybe = windowMaybeImpl Just Nothing

getPath :: Array String -> Window -> Effect (Array String)
getPath basePath w = do
  pathname <- pathname =<< location w
  pure $ drop (length basePath) $ filter (_ /= "") $ split (Pattern "/") pathname
