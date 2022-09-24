module Jelly.Generator.HTML where

import Prelude

import Data.Array (init)
import Data.Maybe (fromMaybe)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Render (render)
import Jelly.Router.Data.Path (makeRelativeFilePath)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (mkdir', writeTextFile)
import Node.FS.Perms (all, mkPerms)

generateHTML :: forall context. Array String -> Record context -> Component context -> Aff Unit
generateHTML output context component = do
  let
    htmlPath = makeRelativeFilePath $ output
  log $ "💫  " <> htmlPath <> " generating..."
  rendered <- liftEffect $ render context component
  mkdir' (makeRelativeFilePath $ fromMaybe [] $ init output)
    { recursive: true, mode: mkPerms all all all }
  writeTextFile UTF8 htmlPath $ rendered
  log $ "🚩  " <> htmlPath <> " generated"
