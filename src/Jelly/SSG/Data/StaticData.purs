module Jelly.SSG.Data.StaticData where

import Prelude

import Affjax.ResponseFormat (string)
import Affjax.Web (get)
import Data.Either (either)
import Data.Maybe (Maybe(..))
import Data.Traversable (for)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Aff, Fiber, joinFiber, launchSuspendedAff)
import Foreign.Object (Object, fromFoldable, lookup)
import Jelly.Core.Components (contextProvider)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Hooks.UseContext (useContext)
import Jelly.Router.Data.Url (makeAbsoluteFilePath)

type StaticData = Object (Fiber String)
type StaticDataContext r = (__staticData :: StaticData | r)

newStaticData :: Array String -> Effect StaticData
newStaticData dataPaths = fromFoldable <$> for dataPaths \dp -> do
  fiber <- launchSuspendedAff do
    res <- get string dp
    pure $ either (\_ -> "") identity $ (_.body) <$> res
  pure $ dp /\ fiber

staticDataProvider
  :: forall r. StaticData -> Component (StaticDataContext r) -> Component r
staticDataProvider staticData component = contextProvider { __staticData: staticData } component

useStaticData :: forall r. Hooks (StaticDataContext r) StaticData
useStaticData = (_.__staticData) <$> useContext

pokeStaticData :: StaticData -> String -> Aff String
pokeStaticData staticData staticDataUrl = do
  let maybeStaticData = lookup staticDataUrl staticData
  case maybeStaticData of
    Just fiber -> joinFiber fiber
    Nothing -> pure ""

dataPath :: Array String -> Array String -> String
dataPath basePath path = makeAbsoluteFilePath $ basePath <> path <> [ "data" ]
