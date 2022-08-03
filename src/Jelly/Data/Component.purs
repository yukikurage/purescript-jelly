module Jelly.Data.Component where

import Prelude

import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook, runHook)
import Jelly.Data.Signal (Signal, launch)
import Web.DOM (Node)
import Web.DOM.Document (createElement, createTextNode)
import Web.DOM.Element (toNode)
import Web.DOM.Node (setNodeValue)
import Web.DOM.Text as TXT
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

newtype Component r = Component (r -> Effect (Node /\ Effect Unit))

runComponent :: forall r. Component r -> r -> Effect (Node /\ Effect Unit)
runComponent (Component f) = f

el :: forall r. String -> Hook r Unit -> Component r
el tag hook = Component \context -> do
  elem <- createElement tag <<< toDocument =<< document =<< window

  _ /\ unmountEffect <- runHook hook context elem

  pure $ (toNode elem) /\ unmountEffect

text :: forall r. Signal String -> Component r
text contentSig = Component \_ -> do
  textNode <- createTextNode "" <<< toDocument =<< document =<< window

  let
    node = TXT.toNode textNode

  unmountEffect <- launch do
    content <- contentSig
    liftEffect $ setNodeValue content node

  pure $ node /\ unmountEffect
