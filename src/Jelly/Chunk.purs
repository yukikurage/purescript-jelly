module Jelly.Chunk where

import Prelude

import Affjax.ResponseFormat (string)
import Affjax.Web (get)
import Data.Either (hush)
import Data.Maybe (Maybe)
import Effect.Aff (Aff)
import Jelly.Util (makeAbsoluteFilePath)

clientChunkData :: forall chunk. Show chunk => chunk -> Aff (Maybe String)
clientChunkData chunk = do
  let
    chunkDataUrl = makeAbsoluteFilePath [ "data", show chunk ]
  res <- get string chunkDataUrl
  pure $ (_.body) <$> hush res
