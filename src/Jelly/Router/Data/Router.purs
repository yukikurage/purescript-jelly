module Jelly.Router.Data.Router where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Foreign (unsafeToForeign)
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (Hooks, makeComponent)
import Jelly.Data.Signal (Signal, signal, writeAtom)
import Jelly.El (contextProvider)
import Jelly.Hooks.UseContext (useContext)
import Jelly.Hooks.UseEventListener (useEventListener)
import Jelly.Router.Data.Config (RouterConfig)
import Jelly.Router.Data.Url (locationToUrl, urlToString)
import Web.HTML (window)
import Web.HTML.Event.PopStateEvent.EventTypes (popstate)
import Web.HTML.History (DocumentTitle(..), URL(..), pushState, replaceState)
import Web.HTML.Window (history, location)
import Web.HTML.Window as Window

type Router page =
  { pageSig :: Signal page
  , pushPage :: page -> Effect Unit
  }

type RouterContext page context = (__router :: Router page | context)

routerProvider
  :: forall context page
   . Eq page
  => RouterConfig page
  -> Component (RouterContext page context)
  -> Component context
routerProvider { basePath, urlToPage, pageToUrl } component = makeComponent do
  w <- liftEffect window
  loc <- liftEffect $ location w
  initialPage <- liftEffect $ urlToPage <$> locationToUrl basePath loc
  pageSig /\ pageAtom <- signal initialPage

  let
    listener = \_ -> do
      url <- locationToUrl basePath loc
      writeAtom pageAtom $ urlToPage url
  useEventListener popstate listener $ Window.toEventTarget w

  liftEffect $
    replaceState (unsafeToForeign {}) (DocumentTitle "")
      (URL $ urlToString basePath $ pageToUrl initialPage)
      =<< history w
  let
    pushPage page = do
      pushState (unsafeToForeign {}) (DocumentTitle "")
        (URL $ urlToString basePath $ pageToUrl page)
        =<< history w
      writeAtom pageAtom page

    router =
      { pageSig
      , pushPage
      }

  pure $ contextProvider { __router: router } component

useRouter :: forall page context. Hooks (RouterContext page context) (Router page)
useRouter = (_.__router) <$> useContext
