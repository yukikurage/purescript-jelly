module Jelly.SSG.ClientMain where

import Prelude

import Affjax.ResponseFormat (string)
import Affjax.Web (get)
import Data.Either (hush)
import Data.Maybe (fromMaybe)
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Jelly.Core.Aff (awaitDocument)
import Jelly.Core.Components (signalC)
import Jelly.Core.Data.Hooks (hooks)
import Jelly.Core.Data.Signal (signalWithoutEq, writeAtom)
import Jelly.Core.Hooks.UseSignal (useSignal)
import Jelly.Core.Mount (hydrate_)
import Jelly.Router.Data.Router (routerProvider, useRouter)
import Jelly.Router.Data.Url (locationToUrl, makeAbsoluteFilePath)
import Jelly.SSG.Data.ClientConfig (ClientConfig)
import Jelly.SSG.Data.StaticData (dataPath, newStaticData, pokeStaticData, staticDataProvider)
import Simple.JSON (readJSON_)
import Web.HTML (window)
import Web.HTML.Window (location)

clientMain :: forall context page. Eq page => ClientConfig context page -> Aff Unit
clientMain
  { rootComponent, pageToUrl, urlToPage, basePath, pageComponent } = do
  w <- liftEffect $ window
  loc <- liftEffect $ location w

  -- Detect Initial Page
  initialPage <- liftEffect $ urlToPage <$> locationToUrl basePath loc

  -- Retrieve page list
  pagesResEither <- get string $ makeAbsoluteFilePath $ basePath <> [ "pages.json" ]
  let pages = fromMaybe [] $ readJSON_ <<< (_.body) =<< hush pagesResEither

  -- Fetch Initial Data
  staticData <- liftEffect $ newStaticData $ map (dataPath basePath) pages
  initialData <- pokeStaticData staticData $ dataPath basePath $ (pageToUrl initialPage).path

  -- Make Routed Component
  componentSig /\ componentAtom <- signalWithoutEq $ pageComponent initialPage
    initialData
  let
    routerSettings =
      { basePath
      , pageToUrl
      , urlToPage
      }
    routedRootComponent = routerProvider routerSettings $ staticDataProvider staticData $ hooks do
      { pageSig } <- useRouter

      useSignal do
        page <- pageSig
        -- Change page component after fetching data
        liftEffect $ launchAff_ do
          dt <- pokeStaticData staticData $ dataPath basePath $ (pageToUrl page).path
          writeAtom componentAtom $ pageComponent page dt
      pure do
        rootComponent do
          signalC componentSig

  -- Hydration
  docInst <- awaitDocument
  liftEffect $ hydrate_ routedRootComponent docInst

  pure unit
