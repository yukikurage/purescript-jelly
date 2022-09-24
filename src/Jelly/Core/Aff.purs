module Jelly.Core.Aff where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe)
import Effect.Aff (Aff, effectCanceler, makeAff)
import Effect.Class (liftEffect)
import Web.DOM (Element)
import Web.DOM.ParentNode (QuerySelector, querySelector)
import Web.Event.EventTarget (addEventListener, eventListener, removeEventListener)
import Web.HTML (HTMLDocument, window)
import Web.HTML.Event.EventTypes (domcontentloaded)
import Web.HTML.HTMLDocument (readyState)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.HTMLDocument.ReadyState (ReadyState(..))
import Web.HTML.Window (document)
import Web.HTML.Window as Window

awaitDomContentLoaded :: Aff Unit
awaitDomContentLoaded = makeAff \callback -> do
  w <- window
  rs <- readyState =<< document =<< window
  case rs of
    Loading -> do
      let
        et = Window.toEventTarget w
      listener <- eventListener $ pure $ callback (Right unit)
      addEventListener domcontentloaded listener false et
      pure $ effectCanceler $ removeEventListener domcontentloaded listener false et
    _ -> do
      callback (Right unit)
      mempty

awaitDocument :: Aff HTMLDocument
awaitDocument = do
  awaitDomContentLoaded
  liftEffect $ document =<< window

awaitQuerySelector :: QuerySelector -> Aff (Maybe Element)
awaitQuerySelector qs = do
  awaitDomContentLoaded
  liftEffect $ querySelector qs <<< HTMLDocument.toParentNode =<< document =<<
    window
