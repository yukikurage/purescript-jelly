module Jelly.Data.Router where

import Prelude

import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Foreign (unsafeToForeign)
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (Hooks, makeComponent)
import Jelly.Data.Signal (Atom, Signal, signal, writeAtom)
import Jelly.El (contextProvider)
import Jelly.Hooks.UseContext (useContext)
import Jelly.Util (makeAbsolutePath)
import Web.HTML (window)
import Web.HTML.History (DocumentTitle(..), URL(..), pushState)
import Web.HTML.Window (history)

type RouterSettings page =
  { basePath :: Array String
  , toPath :: page -> Array String
  , initialPage :: page
  }

newtype Router page = Router
  { basePath :: Array String
  , toPath :: page -> Array String
  , currentPage :: Signal page /\ Atom page
  }

type RouterContext page r = (jelly_router :: Router page | r)

newRouter
  :: forall page
   . Eq page
  => RouterSettings page
  -> Effect (Router page)
newRouter { basePath: bp, toPath, initialPage } = do
  pageSig /\ pageAtom <- signal initialPage
  pure $ Router
    { basePath: bp
    , toPath
    , currentPage: pageSig /\ pageAtom
    }

routerProvider
  :: forall context page
   . Eq page
  => RouterSettings page
  -> Component (jelly_router :: Router page | context)
  -> Component context
routerProvider routerSettings component = makeComponent do
  router <- liftEffect $ newRouter routerSettings
  pure $ contextProvider { jelly_router: router } component

useRouter :: forall page r. Hooks (jelly_router :: page | r) page
useRouter = (_.jelly_router) <$> useContext

currentPage :: forall page. Router page -> Signal page
currentPage (Router { currentPage: pageSig /\ _ }) = pageSig

basePath :: forall page. Router page -> Array String
basePath (Router { basePath: bp }) = bp

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
  pushState (unsafeToForeign {}) (DocumentTitle "") (URL $ makeAbsolutePath $ bp <> toPath page) hst
