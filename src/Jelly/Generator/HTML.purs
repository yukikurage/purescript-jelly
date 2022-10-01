module Jelly.Generator.HTML where

import Prelude

import Control.Parallel (parTraverse_)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Render (render)
import Jelly.Router.Data.Path (Path, makeRelativeFilePath)
import Jelly.Router.Data.Router (RouterContext, mockRouter, provideRouterContext)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (mkdir', writeTextFile)
import Node.FS.Perms (all, mkPerms)

generateHTML
  :: forall context
   . Array String
  -> Array Path
  -> Record context
  -> Component (RouterContext context)
  -> Aff Unit
generateHTML output paths context component = flip parTraverse_ paths \path -> do
  let
    htmlPath = makeRelativeFilePath $ output <> path <> [ "index.html" ]
  router <- liftEffect $ mockRouter { path, query: mempty, hash: mempty }
  rendered <- liftEffect $ render (provideRouterContext router context) component
  mkdir' (makeRelativeFilePath (output <> path)) { recursive: true, mode: mkPerms all all all }
  writeTextFile UTF8 htmlPath $ rendered
