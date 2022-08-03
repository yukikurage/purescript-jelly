module Jelly.HTML where

import Prelude

import Control.Safely (for_)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook, runHookWithCurrentContext)
import Jelly.Data.Signal (Signal)
import Jelly.Hooks.UseChildNodes (useChildNodes)
import Jelly.Hooks.UseDeferSignal (useDeferSignal)
import Jelly.Hooks.UseSignal (useSignal)
import Web.DOM (Element, Node)
import Web.DOM.Document (createElement, createTextNode)
import Web.DOM.Element (setAttribute, toNode)
import Web.DOM.Node (setNodeValue)
import Web.DOM.Text as Text
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

attributeSignal
  :: Element
  -> String
  -> Signal String
  -> Signal Unit
attributeSignal element attr signal = do
  val <- signal
  liftEffect $ setAttribute attr val element

el :: forall r. String -> Hook r Unit -> Hook r Unit
el tag hook = do
  elem <- liftEffect $ createElement tag <<< toDocument =<< document =<< window

  { childNodes, attributes, deferEffect } <- runHookWithCurrentContext hook

  for_ attributes \(attr /\ signal) -> useSignal $ attributeSignal elem attr
    signal

  useDeferSignal $ liftEffect deferEffect

  useSignal $ liftEffect <<< updateNodeChildren (toNode elem) =<< childNodes

  useChildNodes $ pure [ toNode elem ]

txt :: forall r. Signal String -> Hook r Unit
txt sig = do
  t <- liftEffect $ createTextNode "" <<< toDocument =<< document =<< window

  useSignal $ liftEffect <<< flip setNodeValue (Text.toNode t) =<< sig

  useChildNodes $ pure [ Text.toNode t ]
