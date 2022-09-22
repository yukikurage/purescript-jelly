module Jelly.SSG.ClientMain where

import Prelude

import Affjax.ResponseFormat (string)
import Affjax.Web (get)
import Data.Either (either)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Jelly.Core.Aff (awaitDocument)
import Jelly.Core.Components (signalC)
import Jelly.Core.Data.Hooks (makeComponent)
import Jelly.Core.Data.Signal (signalWithoutEq, writeAtom)
import Jelly.Core.Hooks.UseSignal (useSignal)
import Jelly.Core.Mount (mount_)
import Jelly.Router.Data.Router (routerProvider, useRouter)
import Jelly.Router.Data.Url (locationToUrl, makeAbsoluteFilePath)
import Jelly.SSG.Data.Config (SsgConfig)
import Web.HTML (window)
import Web.HTML.Window (location)

foreign import getDataImpl
  :: (String -> Maybe String) -> Maybe String -> String -> Effect (Maybe String)

foreign import setData :: String -> String -> Effect Unit

getData :: String -> Effect (Maybe String)
getData key = getDataImpl Just Nothing key

clientMain :: forall context page. Eq page => SsgConfig context page -> Aff Unit
clientMain
  { rootComponent, pageToUrl, urlToPage, basePath, pageComponent } = do
  w <- liftEffect $ window
  loc <- liftEffect $ location w

  -- Detect Initial Page
  initialPage <- liftEffect $ urlToPage <$> locationToUrl basePath loc

  -- Fetch Initial Data
  let
    clientData page = do
      let
        dataUrl = makeAbsoluteFilePath $ basePath <> (pageToUrl page).path <> [ "data" ]
      dataMaybe <- liftEffect $ getData dataUrl
      case dataMaybe of
        Just dt -> pure dt
        Nothing -> do
          res <- get string dataUrl
          let newData = either (\_ -> "") identity $ (_.body) <$> res
          liftEffect $ setData dataUrl newData
          pure newData
  initialData <- clientData initialPage

  -- Make Routed Component
  componentSig /\ componentAtom <- signalWithoutEq $ (pageComponent initialPage).component
    initialData
  let
    routerSettings =
      { basePath
      , pageToUrl
      , urlToPage
      }
    routedRootComponent = routerProvider routerSettings $ makeComponent do
      { pageSig } <- useRouter

      useSignal do
        page <- pageSig
        liftEffect $ launchAff_ do
          dt <- clientData page
          writeAtom componentAtom $ (pageComponent page).component dt
      pure do
        rootComponent do
          signalC componentSig

  -- Mount
  docInst <- awaitDocument
  liftEffect $ mount_ routedRootComponent docInst

  pure unit
