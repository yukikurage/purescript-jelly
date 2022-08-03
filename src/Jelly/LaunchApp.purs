module Jelly.LaunchApp where

import Prelude

import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook, runHook)
import Jelly.Data.Signal (launch_)
import Jelly.HTML (attributeSignal, updateNodeChildren)
import Web.DOM.Element (toNode)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toElement)
import Web.HTML.Window (document)

launchApp :: forall r. Hook r Unit -> r -> Effect Unit
launchApp hook context = do
  bm <- body =<< document =<< window

  case bm of
    Nothing -> pure unit
    Just b -> do
      let
        bElem = toElement b

      { childNodes, attributes } <- runHook hook context

      for_ attributes \(attr /\ signal) -> launch_ $ attributeSignal bElem attr
        signal

      launch_ do
        cns <- childNodes
        liftEffect $ updateNodeChildren (toNode bElem) cns
