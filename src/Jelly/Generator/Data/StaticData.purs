module Jelly.Generator.Data.StaticData where

import Prelude

import Affjax.ResponseFormat (string)
import Affjax.Web (get)
import Control.Parallel (parTraverse)
import Data.Either (hush)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff, Fiber, joinFiber, launchSuspendedAff)
import Effect.Class (liftEffect)
import Foreign.Object (Object, fromFoldable, lookup)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Hooks.UseContext (useContext)
import Jelly.Router.Data.Path (Path, makeAbsoluteDirPath, makeAbsoluteFilePath, makeRelativeFilePath)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (mkdir', writeTextFile)
import Node.FS.Perms (all, mkPerms)
import Record (union)
import Simple.JSON (readJSON_)

type StaticData = Object (Fiber String)

type StaticDataContext context = (__staticData :: StaticData | context)

newStaticData :: Path -> Aff StaticData
newStaticData basePath = do
  pathsResEither <- get string $ makeAbsoluteFilePath $ basePath <> [ "paths.json" ]
  let paths = fromMaybe [] $ readJSON_ <<< (_.body) =<< hush pathsResEither

  fromFoldable <$> flip parTraverse paths \path -> liftEffect do
    fiber <- launchSuspendedAff do
      dataResEither <- get string $ makeAbsoluteFilePath $ basePath <> path <> [ "data" ]
      pure $ fromMaybe "" $ readJSON_ <<< (_.body) =<< hush dataResEither
    pure $ makeAbsoluteDirPath path /\ fiber

loadStaticData :: StaticData -> Path -> Aff (Maybe String)
loadStaticData staticData path = case lookup (makeAbsoluteDirPath path) staticData of
  Just fiber -> Just <$> joinFiber fiber
  Nothing -> pure Nothing

mockStaticData :: Array String -> Array Path -> (Path -> Aff String) -> Aff StaticData
mockStaticData output paths get = do
  fromFoldable <$> flip parTraverse paths \path -> do
    fiber <- liftEffect $ launchSuspendedAff $ get path
    dt <- joinFiber fiber
    let
      dataPath = makeRelativeFilePath $ output <> path <> [ "data" ]
    mkdir' (makeRelativeFilePath path)
      { recursive: true, mode: mkPerms all all all }
    writeTextFile UTF8 dataPath dt
    pure $ makeAbsoluteDirPath path /\ fiber

provideStaticDataContext
  :: forall context. StaticData -> Record context -> Record (StaticDataContext context)
provideStaticDataContext staticData context = union { __staticData: staticData } context

useStaticData :: forall context. Hooks (StaticDataContext context) StaticData
useStaticData = (_.__staticData) <$> useContext
