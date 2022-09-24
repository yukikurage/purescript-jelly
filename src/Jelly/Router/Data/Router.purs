module Jelly.Router.Data.Router where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Foreign (unsafeToForeign)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Data.Signal (Signal, signal, writeAtom)
import Jelly.Core.Hooks.UseContext (useContext)
import Jelly.Router.Data.Url (Url, locationToUrl, urlToString)
import Record (union)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML (window)
import Web.HTML.Event.PopStateEvent.EventTypes (popstate)
import Web.HTML.History (DocumentTitle(..), URL(..), pushState, replaceState)
import Web.HTML.Window (history, location)
import Web.HTML.Window as Window

type Router =
  { currentUrlSig :: Signal Url
  , isTransitioningSig :: Signal Boolean
  , pushUrl :: Url -> Effect Unit
  , replaceUrl :: Url -> Effect Unit
  }

type RouterContext context = (__router :: Router | context)

-- | Create a mock router
-- | It is useful for rendering a component on node.js
mockRouter :: Url -> (Url -> Aff Url) -> Aff Router
mockRouter initialUrl transition = do
  newInitialUrl <- transition initialUrl

  currentUrlSig /\ currentUrlAtom <- signal newInitialUrl
  isTransitioningSig /\ isTransitioningAtom <- signal false

  let
    handleUrl url = do
      writeAtom isTransitioningAtom true
      launchAff_ do
        newUrl <- transition url
        writeAtom currentUrlAtom newUrl
        writeAtom isTransitioningAtom false

  pure
    { currentUrlSig
    , pushUrl: handleUrl
    , isTransitioningSig
    , replaceUrl: handleUrl
    }

-- | Create a router
-- | On push or replace Url:
-- |   1. Set isTransitioning to true
-- |   2. Run the transition Aff
-- |   3. Update the url of the browser again (in case the transition changed it)
-- |   4. Update the currentUrlSig with the new url
-- | On the browser url changing:
-- |   1. Run the transition Aff
-- |   2. Update url of the browser
-- |   3. Update the currentUrlSig with the new url
newRouter :: (Url -> Aff Url) -> Aff Router
newRouter transition = do
  w <- liftEffect window
  loc <- liftEffect $ location w

  initialUrl <- liftEffect $ locationToUrl loc
  newInitialUrl <- transition initialUrl
  liftEffect $
    replaceState (unsafeToForeign {}) (DocumentTitle "")
      (URL $ urlToString newInitialUrl) =<< history w

  currentUrlSig /\ currentUrlAtom <- signal newInitialUrl
  isTransitioningSig /\ isTransitioningAtom <- signal false

  listener <- liftEffect $ eventListener \_ -> do
    url <- locationToUrl loc
    launchAff_ do
      newUrl <- transition url
      liftEffect $
        replaceState (unsafeToForeign {}) (DocumentTitle "")
          (URL $ urlToString newUrl) =<< history w
      writeAtom currentUrlAtom newUrl

  liftEffect $ addEventListener popstate listener false $ Window.toEventTarget w

  let
    handleUrl handleFn url = do
      writeAtom isTransitioningAtom true
      launchAff_ do
        newUrl <- transition url
        liftEffect $
          handleFn (unsafeToForeign {}) (DocumentTitle "")
            (URL $ urlToString newUrl) =<< history w
        writeAtom currentUrlAtom newUrl
        writeAtom isTransitioningAtom false
    pushUrl url = handleUrl pushState url
    replaceUrl url = handleUrl replaceState url

  pure
    { currentUrlSig
    , pushUrl
    , isTransitioningSig
    , replaceUrl
    }

provideRouterContext :: forall context. Router -> Record context -> Record (RouterContext context)
provideRouterContext router context = { __router: router } `union` context

useRouter :: forall context. Hooks (RouterContext context) Router
useRouter = (_.__router) <$> useContext
