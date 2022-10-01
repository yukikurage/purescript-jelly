module Jelly.Generator.Data.StaticData where

import Prelude

import Affjax.ResponseFormat (string)
import Affjax.Web (get)
import Control.Parallel (parTraverse)
import Data.Either (hush)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff, joinFiber, launchSuspendedAff)
import Effect.Class (liftEffect)
import Foreign.Object (fromFoldable, lookup)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Hooks.UseContext (useContext)
import Jelly.Router.Data.Path (Path, makeAbsoluteDirPath, makeAbsoluteFilePath)
import Record (union)
import Simple.JSON (readJSON_)

type StaticData = { loadData :: Path -> Aff (Maybe String), globalData :: String }

type StaticDataContext context = (__staticData :: StaticData | context)

newStaticData :: Path -> Aff StaticData
newStaticData basePath = do
  pathsResEither <- get string $ makeAbsoluteFilePath $ basePath <> [ "paths.json" ]
  let paths = fromMaybe [] $ readJSON_ <<< (_.body) =<< hush pathsResEither

  pageData <- fromFoldable <$> flip parTraverse paths \path -> liftEffect do
    fiber <- launchSuspendedAff do
      dataResEither <- get string $ makeAbsoluteFilePath $ basePath <> path <> [ "data" ]
      pure $ fromMaybe "" $ readJSON_ <<< (_.body) =<< hush dataResEither
    pure $ makeAbsoluteDirPath path /\ fiber

  let
    loadData path = case lookup (makeAbsoluteDirPath path) pageData of
      Just fiber -> Just <$> joinFiber fiber
      Nothing -> pure Nothing

  globalResEither <- get string $ makeAbsoluteFilePath $ basePath <> [ "global" ]
  let
    globalData = fromMaybe "" $ readJSON_ <<< (_.body) =<< hush globalResEither

  pure
    { loadData
    , globalData
    }

provideStaticDataContext
  :: forall context. StaticData -> Record context -> Record (StaticDataContext context)
provideStaticDataContext staticData context = union { __staticData: staticData } context

useStaticData :: forall context. Hooks (StaticDataContext context) StaticData
useStaticData = (_.__staticData) <$> useContext
