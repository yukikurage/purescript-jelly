module Jelly.ClientMain where

import Prelude

import Affjax.ResponseFormat (string)
import Affjax.Web (get)
import Data.Either (either)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitDocument)
import Jelly.Data.Config (Config)
import Jelly.Data.Hooks (makeComponent)
import Jelly.Data.Router (routerProvider, useRouter)
import Jelly.Data.Signal (signalWithoutEq, writeAtom)
import Jelly.Data.Url (locationToUrl, makeAbsoluteFilePath)
import Jelly.El (signalC)
import Jelly.Hooks.UseSignal (useSignal)
import Jelly.Mount (mount_)
import Web.HTML (window)
import Web.HTML.Window (location)

foreign import getDataImpl
  :: (String -> Maybe String) -> Maybe String -> String -> Effect (Maybe String)

foreign import setData :: String -> String -> Effect Unit

getData :: String -> Effect (Maybe String)
getData key = getDataImpl Just Nothing key

clientMain :: forall context page. Eq page => Config context page -> Aff Unit
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
      , initialPage
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
