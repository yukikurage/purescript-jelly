module Jelly.Router.Data.Router where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Ref (modify_, new, read)
import Foreign (unsafeToForeign)
import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Signal (Signal, newStateEq, writeAtom)
import Jelly.Hooks.UseContext (useContext)
import Jelly.Router.Data.Path (Path)
import Jelly.Router.Data.Url (Url, locationToUrl, urlToString)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML (window)
import Web.HTML.Event.PopStateEvent.EventTypes (popstate)
import Web.HTML.History (DocumentTitle(..), URL(..), pushState, replaceState)
import Web.HTML.Window (history, location)
import Web.HTML.Window as Window

type Router =
  { basePath :: Path
  , currentUrlSig :: Signal Url
  , temporaryUrlSig :: Signal Url
  , isTransitioningSig :: Signal Boolean
  , pushUrl :: Url -> Effect Unit
  , replaceUrl :: Url -> Effect Unit
  }

class RouterContext context where
  getRouter :: context -> Router

useRouter :: forall context. RouterContext context => Hooks context Router
useRouter = getRouter <$> useContext

-- | Create a mock router
-- | It is useful for rendering a component on node.js
newMockRouter :: Url -> Effect Router
newMockRouter initialUrl = pure
  { basePath: []
  , currentUrlSig: pure initialUrl
  , temporaryUrlSig: pure initialUrl
  , pushUrl: mempty
  , isTransitioningSig: pure false
  , replaceUrl: mempty
  }

-- | Create a router
-- | On push or replace Url:
-- |   1. Set isTransitioning to true
-- |   2. Update the currentUrlSig
-- |   3. Run the transition Aff
-- |   4. Update the url of the browser
-- |   5. Update the currentUrlSig with the new url
-- | On the browser url changing:
-- |   1. Set isTransitioning to true
-- |   2. Update the currentUrlSig
-- |   3. Run the transition Aff
-- |   4. Update url of the browser
-- |   5. Update the currentUrlSig with the new url
newRouter :: Path -> (Url -> Aff Url) -> Aff Router
newRouter basePath transition = do
  w <- liftEffect window
  loc <- liftEffect $ location w

  initialUrl <- liftEffect $ locationToUrl basePath loc

  newInitialUrl <- transition initialUrl
  liftEffect $
    replaceState (unsafeToForeign {}) (DocumentTitle "")
      (URL $ urlToString basePath newInitialUrl) =<< history w

  currentUrlSig /\ currentUrlAtom <- newStateEq newInitialUrl
  temporaryUrlSig /\ temporaryUrlAtom <- newStateEq newInitialUrl
  isTransitioningSig /\ isTransitioningAtom <- newStateEq false

  currentRef <- liftEffect $ new 0

  let
    handleUrl handleFn url = do
      modify_ (_ + 1) currentRef
      current <- read currentRef
      writeAtom isTransitioningAtom true
      writeAtom temporaryUrlAtom url
      launchAff_ do
        newUrl <- transition url
        finished <- liftEffect $ read currentRef
        when (current == finished) $ liftEffect do
          handleFn (unsafeToForeign {}) (DocumentTitle "")
            (URL $ urlToString basePath newUrl) =<< history w
          writeAtom isTransitioningAtom false
          writeAtom currentUrlAtom newUrl
          writeAtom temporaryUrlAtom newUrl
    pushUrl = handleUrl pushState
    replaceUrl = handleUrl replaceState

  listener <- liftEffect $ eventListener \_ -> locationToUrl basePath loc >>= handleUrl replaceState

  liftEffect $ addEventListener popstate listener false $ Window.toEventTarget w

  pure
    { basePath
    , currentUrlSig
    , temporaryUrlSig
    , pushUrl
    , isTransitioningSig
    , replaceUrl
    }
