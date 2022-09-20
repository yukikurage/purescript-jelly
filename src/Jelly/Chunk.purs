module Jelly.Chunk where

import Prelude

import Affjax.ResponseFormat (string)
import Affjax.Web (get)
import Data.Either (hush)
import Data.Maybe (Maybe)
import Effect.Aff (Aff)
import Jelly.Util (makeAbsoluteFilePath)

clientChunkData :: forall chunk. Show chunk => Array String -> chunk -> Aff (Maybe String)
clientChunkData basePath chunk = do
  let
    chunkDataUrl = makeAbsoluteFilePath $ basePath <> [ "data", show chunk ]
  res <- get string chunkDataUrl
  pure $ (_.body) <$> hush res
