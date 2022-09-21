module Jelly.Data.Router where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Effect.Ref (new, read, write)
import Foreign (unsafeToForeign)
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (Hooks, makeComponent)
import Jelly.Data.Query (Query)
import Jelly.Data.Signal (Atom, Signal, signal, writeAtom)
import Jelly.Data.Url (locationToUrl, urlToString)
import Jelly.El (contextProvider)
import Jelly.Hooks.UseContext (useContext)
import Jelly.Hooks.UseEventListener (useEventListener)
import Jelly.Hooks.UseSignal (useSignal)
import Web.HTML (window)
import Web.HTML.Event.PopStateEvent.EventTypes (popstate)
import Web.HTML.History (DocumentTitle(..), URL(..), pushState, replaceState)
import Web.HTML.Window (history, location)
import Web.HTML.Window as Window

type RouterSettings page =
  { basePath :: Array String
  , pageToUrl ::
      page
      -> { path :: Array String
         , query :: Query
         , hash :: String
         }
  , urlToPage :: { path :: Array String, query :: Query, hash :: String } -> page
  , initialPage :: page
  }

type Router page =
  { pageSig :: Signal page
  , pageAtom :: Atom page
  }

type RouterContext page context = (__router :: Router page | context)

routerProvider
  :: forall context page
   . Eq page
  => RouterSettings page
  -> Component (RouterContext page context)
  -> Component context
routerProvider { basePath, urlToPage, pageToUrl, initialPage } component = makeComponent do
  pageSig /\ pageAtom <- signal initialPage

  w <- liftEffect window
  loc <- liftEffect $ location w

  let
    listener = \_ -> do
      url <- locationToUrl basePath loc
      writeAtom pageAtom $ urlToPage url
  useEventListener popstate listener $ Window.toEventTarget w

  isFirstRef <- liftEffect $ new true

  useSignal do
    page <- pageSig
    liftEffect do
      isFirst <- read isFirstRef
      let
        url = pageToUrl page
        handleState = if isFirst then replaceState else pushState
      handleState (unsafeToForeign {}) (DocumentTitle "")
        (URL $ urlToString basePath url)
        =<< history w
      write false isFirstRef
  let
    router =
      { pageSig
      , pageAtom
      }

  pure $ contextProvider { __router: router } component

useRouter :: forall page context. Hooks (RouterContext page context) (Router page)
useRouter = (_.__router) <$> useContext
