module Jelly.Generator.StaticData where

import Prelude

import Effect.Aff (Aff)
import Effect.Class.Console (log)
import Jelly.Router.Data.Path (makeRelativeFilePath)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (mkdir', writeTextFile)
import Node.FS.Perms (all, mkPerms)
import Simple.JSON (class WriteForeign, writeJSON)

generateStaticData :: forall a. WriteForeign a => Array String -> Aff a -> Aff a
generateStaticData output fetchData = do
  let
    dataPath = makeRelativeFilePath output
  log $ "💫  " <> dataPath <> " generating..."
  dt <- fetchData
  mkdir' (makeRelativeFilePath output) { recursive: true, mode: mkPerms all all all }
  writeTextFile UTF8 dataPath $ writeJSON dt
  log $ "🚩  " <> dataPath <> " generated"
  pure $ dt
