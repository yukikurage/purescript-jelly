module Jelly.Data.Router where

import Prelude

import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Foreign (unsafeToForeign)
import Jelly.Data.Signal (Atom, Signal, signal, writeAtom)
import Web.HTML (window)
import Web.HTML.History (DocumentTitle(..), URL(..), pushState)
import Web.HTML.Window (history)

data Router page = Router
  { basePath :: String
  , toPath :: page -> String
  , currentPage :: Signal page /\ Atom page
  }

newRouter
  :: forall page
   . Eq page
  => { basePath :: String
     , toPath :: page -> String
     , initialPage :: page
     }
  -> Effect (Router page)
newRouter { basePath, toPath, initialPage } = do
  pageSig /\ pageAtom <- signal initialPage
  pure $ Router
    { basePath
    , toPath
    , currentPage: pageSig /\ pageAtom
    }

currentPage :: forall page. Router page -> Signal page
currentPage (Router { currentPage: pageSig /\ _ }) = pageSig

getBasePath :: forall page. Router page -> String
getBasePath (Router { basePath: bp }) = bp

pushPage :: forall page. Router page -> page -> Effect Unit
pushPage
  ( Router
      { toPath
      , basePath
      , currentPage: _ /\ pageAtom
      }
  )
  page = do
  writeAtom pageAtom page
  hst <- history =<< window
  pushState (unsafeToForeign {}) (DocumentTitle "") (URL $ basePath <> toPath page) hst
