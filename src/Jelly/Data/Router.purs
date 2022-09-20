module Jelly.Data.Router where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Foreign (unsafeToForeign)
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (Hooks, makeComponent)
import Jelly.Data.Query (Query, fromSearch, toSearch)
import Jelly.Data.Signal (Atom, Signal, signal, writeAtom)
import Jelly.El (contextProvider)
import Jelly.Hooks.UseContext (useContext)
import Jelly.Hooks.UseEventListener (useEventListener)
import Jelly.Hooks.UseSignal (useSignal)
import Jelly.Util (dropBasePath, makeAbsoluteUrlPath, pathToArray, windowMaybe)
import Web.HTML.Event.PopStateEvent.EventTypes (popstate)
import Web.HTML.History (DocumentTitle(..), URL(..), pushState)
import Web.HTML.Location (hash, pathname, search)
import Web.HTML.Window (history, location)
import Web.HTML.Window as Window

type RouterSettings page =
  { basePath :: Array String
  , toUrl ::
      page
      -> { path :: Array String
         , query :: Query
         , hash :: String
         }
  , fromUrl :: { path :: Array String, query :: Query, hash :: String } -> page
  , initialPage :: page
  }

type Router page =
  { basePath :: Array String
  , toUrl ::
      page
      -> { path :: Array String
         , query :: Query
         , hash :: String
         }
  , fromUrl :: { path :: Array String, query :: Query, hash :: String } -> page
  , pageSig :: Signal page
  , pageAtom :: Atom page
  }

type RouterContext page context = (__router :: Router page | context)

routerProvider
  :: forall context page
   . Eq page
  => RouterSettings page
  -> Component (RouterContext page context)
  -> Component context
routerProvider { basePath: bp, fromUrl, toUrl, initialPage } component = makeComponent do
  pageSig /\ pageAtom <- signal initialPage

  wM <- liftEffect $ windowMaybe

  case wM of
    Just w -> do
      let
        listener = \_ -> do
          pn <- pathname =<< location w
          sr <- search =<< location w
          hs <- hash =<< location w
          let
            path = dropBasePath bp $ pathToArray pn
            query = fromSearch sr
          writeAtom pageAtom $ fromUrl { path, query, hash: hs }
      useEventListener popstate listener $ Window.toEventTarget w
    Nothing -> pure unit

  useSignal do
    page <- pageSig
    liftEffect case wM of
      Nothing -> pure unit
      Just w -> do
        hst <- history $ w
        let
          url = toUrl page
          path = makeAbsoluteUrlPath $ bp <> url.path
          search = case toSearch url.query of
            "" -> ""
            s -> "?" <> s
          hash = case url.hash of
            "" -> ""
            h -> "#" <> h
        pushState (unsafeToForeign {}) (DocumentTitle "")
          (URL $ path <> search <> hash)
          hst

  let
    router =
      { basePath: bp
      , toUrl
      , fromUrl
      , pageSig
      , pageAtom
      }

  pure $ contextProvider { __router: router } component

useRouter :: forall page context. Hooks (RouterContext page context) (Router page)
useRouter = (_.__router) <$> useContext
