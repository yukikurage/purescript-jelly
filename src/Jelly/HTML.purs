module Jelly.HTML where

import Prelude

import Control.Safely (for_)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook, runHookWithCurrentContext)
import Jelly.Data.Signal (Signal)
import Jelly.Hooks.UseDeferSignal (useDeferSignal)
import Jelly.Hooks.UseSignal (useSignal)
import Web.DOM (Element, Node)
import Web.DOM.Document (createElement)
import Web.DOM.Element (setAttribute)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

foreign import updateNodeChildren :: Node -> Array Node -> Effect Unit

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

  pure unit
