module Jelly.Generator.Generate where

import Prelude

import Effect.Aff (Aff)
import Effect.Class.Console (log)
import Jelly.Core.Data.Component (Component)
import Jelly.Generator.Data.StaticData (StaticDataContext, provideStaticDataContext)
import Jelly.Generator.HTML (generateHTML)
import Jelly.Generator.Script (generateScript)
import Jelly.Generator.StaticData (mockStaticData)
import Jelly.Router.Data.Path (Path)
import Jelly.Router.Data.Router (RouterContext)

generate
  :: forall context
   . Record context
  -> Config context
  -> Aff Unit
generate context { output, clientMain, paths, getStaticData, globalData, component } = do
  staticData <- mockStaticData output paths getStaticData globalData
  let
    context' = provideStaticDataContext staticData context
  log $ "💫  Script generating..."
  generateScript output clientMain
  log $ "🚩  Script generated"
  log $ "💫  HTML generating..."
  generateHTML output paths context' component
  log $ "🚩  HTML generated"

type Config context =
  { output :: Array String
  , clientMain :: String
  , paths :: Array Path
  , getStaticData :: Path -> Aff String
  , globalData :: String
  , component :: Component (RouterContext (StaticDataContext context))
  }
