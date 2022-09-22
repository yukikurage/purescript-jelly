module Jelly.SSG.Data.StaticData where

import Prelude

import Affjax.ResponseFormat (string)
import Affjax.Web (get)
import Control.Monad.ST.Global (Global, toEffect)
import Data.Either (either)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff, Fiber, joinFiber, launchAff)
import Effect.Class (liftEffect)
import Foreign.Object.ST (STObject, new, peek, poke)
import Jelly.Core.Components (contextProvider)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Hooks.UseContext (useContext)
import Jelly.Router.Data.Url (Url, makeAbsoluteFilePath)

type StaticDataContext r = (__staticData :: STObject Global (Fiber String) | r)

newStaticData :: Effect (STObject Global (Fiber String))
newStaticData = toEffect $ new

staticDataProvider
  :: forall r. STObject Global (Fiber String) -> Component (StaticDataContext r) -> Component r
staticDataProvider staticData component = contextProvider { __staticData: staticData } component

useStaticData :: forall r. Hooks (StaticDataContext r) (STObject Global (Fiber String))
useStaticData = (_.__staticData) <$> useContext

pokeStaticData :: STObject Global (Fiber String) -> String -> Aff String
pokeStaticData staticData staticDataUrl = joinFiber =<< liftEffect do
  maybeStaticData <- toEffect $ peek staticDataUrl staticData
  case maybeStaticData of
    Just sd -> pure sd
    Nothing -> do
      fiber <- launchAff do
        res <- get string staticDataUrl
        let newData = either (\_ -> "") identity $ (_.body) <$> res
        pure newData
      _ <- toEffect $ poke staticDataUrl fiber staticData
      pure fiber

dataPath :: Array String -> Url -> String
dataPath basePath pageToUrl = makeAbsoluteFilePath $ basePath <> pageToUrl.path <> [ "data" ]
