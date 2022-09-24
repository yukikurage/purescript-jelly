module Jelly.Generator.Data.StaticData where

import Prelude

import Affjax.ResponseFormat (string)
import Affjax.Web (get)
import Data.Either (hush)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff, Fiber, joinFiber, launchSuspendedAff)
import Jelly.Router.Data.Path (makeAbsoluteFilePath)
import Simple.JSON (class ReadForeign, readJSON_)

type StaticData a = Fiber (Maybe a)

newStaticData :: forall a. ReadForeign a => Array String -> Effect (StaticData a)
newStaticData dataPath = do
  launchSuspendedAff do
    res <- get string $ makeAbsoluteFilePath $ dataPath
    pure $ readJSON_ =<< (_.body) <$> hush res

loadStaticData :: forall a. ReadForeign a => StaticData a -> Aff (Maybe a)
loadStaticData staticData = joinFiber staticData

mockStaticData :: forall a. a -> StaticData a
mockStaticData = pure <<< Just
