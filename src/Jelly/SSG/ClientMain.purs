module Jelly.SSG.ClientMain where

import Prelude

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
import Jelly.Router.Data.Url (locationToUrl)
import Jelly.SSG.Data.Config (SsgConfig)
import Jelly.SSG.Data.StaticData (dataPath, getStaticData, newStaticData, staticDataProvider)
import Web.HTML (window)
import Web.HTML.Window (location)

clientMain :: forall context page. Eq page => SsgConfig context page -> Aff Unit
clientMain
  { rootComponent, pageToUrl, urlToPage, basePath, pageComponent } = do
  w <- liftEffect $ window
  loc <- liftEffect $ location w

  -- Detect Initial Page
  initialPage <- liftEffect $ urlToPage <$> locationToUrl basePath loc

  -- Fetch Initial Data
  staticData <- liftEffect newStaticData
  initialData <- getStaticData staticData $ dataPath pageToUrl initialPage

  -- Make Routed Component
  componentSig /\ componentAtom <- signalWithoutEq $ (pageComponent initialPage).component
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
          dt <- getStaticData staticData $ dataPath pageToUrl page
          writeAtom componentAtom $ (pageComponent page).component dt
      pure do
        rootComponent do
          signalC componentSig

  -- Hydration
  docInst <- awaitDocument
  liftEffect $ hydrate_ routedRootComponent docInst

  pure unit
