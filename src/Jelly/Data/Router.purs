module Jelly.Data.Router where

import Prelude

import Data.Maybe (Maybe)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Foreign (unsafeToForeign)
import Jelly.Data.Signal (Atom, Signal, signal, writeAtom)
import Web.HTML (window)
import Web.HTML.History (DocumentTitle(..), URL(..), pushState)
import Web.HTML.Window (history)

data Router page = Router (page -> String) (String -> Maybe page) (Signal page /\ Atom page)

newRouter
  :: forall page
   . Eq page
  => (page -> String)
  -> (String -> Maybe page)
  -> page
  -> Effect (Router page)
newRouter toPath fromPath initialPage = do
  pageSig /\ pageAtom <- signal initialPage
  pure $ Router toPath fromPath $ pageSig /\ pageAtom

currentPage :: forall page. Router page -> Signal page
currentPage (Router _ _ (pageSig /\ _)) = pageSig

pushPage :: forall page. Router page -> page -> Effect Unit
pushPage (Router toPath _ (_ /\ pageAtom)) page = do
  writeAtom pageAtom page
  hst <- history =<< window
  pushState (unsafeToForeign {}) (DocumentTitle "") (URL $ toPath page) hst
