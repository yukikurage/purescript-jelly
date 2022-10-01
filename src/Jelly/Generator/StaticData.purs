module Jelly.Generator.StaticData where

import Prelude

import Control.Parallel (parTraverse)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff)
import Foreign.Object (fromFoldable, lookup)
import Jelly.Generator.Data.StaticData (StaticData)
import Jelly.Router.Data.Path (Path, makeAbsoluteDirPath, makeRelativeFilePath)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (mkdir', writeTextFile)
import Node.FS.Perms (all, mkPerms)

mockStaticData :: Array String -> Array Path -> (Path -> Aff String) -> Aff String -> Aff StaticData
mockStaticData output paths getPageData getGlobalData = do
  pageData <- fromFoldable <$> flip parTraverse paths \path -> do
    dt <- getPageData path
    let
      dataPath = makeRelativeFilePath $ output <> path <> [ "data" ]
    mkdir' (makeRelativeFilePath path)
      { recursive: true, mode: mkPerms all all all }
    writeTextFile UTF8 dataPath dt
    pure $ makeAbsoluteDirPath path /\ dt

  let
    loadData path = case lookup (makeAbsoluteDirPath path) pageData of
      Just dt -> pure $ Just dt
      Nothing -> pure Nothing

  globalData <- getGlobalData
  let
    globalPath = makeRelativeFilePath $ output <> [ "global" ]
  writeTextFile UTF8 globalPath globalData

  pure
    { loadData
    , globalData
    }
