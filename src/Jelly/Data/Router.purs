module Jelly.Data.Router where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Foreign (unsafeToForeign)
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (Hooks, makeComponent)
import Jelly.Data.Signal (Atom, Signal, signal, writeAtom)
import Jelly.El (contextProvider)
import Jelly.Hooks.UseContext (useContext)
import Jelly.Hooks.UseEventListener (useEventListener)
import Jelly.Util (getPath, makeAbsoluteUrlPath, windowMaybe)
import Web.HTML (window)
import Web.HTML.Event.PopStateEvent.EventTypes (popstate)
import Web.HTML.History (DocumentTitle(..), URL(..), pushState)
import Web.HTML.Window (history)
import Web.HTML.Window as Window

type RouterSettings page =
  { basePath :: Array String
  , toPath :: page -> Array String
  , fromPath :: Array String -> page
  , initialPage :: page
  }

newtype Router page = Router
  { basePath :: Array String
  , toPath :: page -> Array String
  , fromPath :: Array String -> page
  , currentPage :: Signal page /\ Atom page
  }

type RouterContext page r = (jelly_router :: Router page | r)

routerProvider
  :: forall context page
   . Eq page
  => RouterSettings page
  -> Component (jelly_router :: Router page | context)
  -> Component context
routerProvider { basePath: bp, fromPath, toPath, initialPage } component = makeComponent do
  pageSig /\ pageAtom <- signal initialPage

  wM <- liftEffect $ windowMaybe

  case wM of
    Just w -> do
      let
        listener = \_ -> do
          path <- liftEffect $ getPath bp w
          writeAtom pageAtom $ fromPath path
      useEventListener popstate listener $ Window.toEventTarget w
    Nothing -> pure unit

  let
    router = Router
      { basePath: bp
      , toPath
      , fromPath
      , currentPage: pageSig /\ pageAtom
      }

  pure $ contextProvider { jelly_router: router } component

useRouter :: forall page r. Hooks (jelly_router :: page | r) page
useRouter = (_.jelly_router) <$> useContext

getCurrentPage :: forall page. Router page -> Signal page
getCurrentPage (Router { currentPage: pageSig /\ _ }) = pageSig

getBasePath :: forall page. Router page -> Array String
getBasePath (Router { basePath: bp }) = bp

pushPage :: forall page. Router page -> page -> Effect Unit
pushPage
  ( Router
      { toPath
      , basePath: bp
      , currentPage: _ /\ pageAtom
      }
  )
  page = do
  writeAtom pageAtom page
  hst <- history =<< window
  pushState (unsafeToForeign {}) (DocumentTitle "") (URL $ makeAbsoluteUrlPath $ bp <> toPath page)
    hst
