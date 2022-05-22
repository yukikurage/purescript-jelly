module Jelly.Hooks.DOM where

import Prelude

import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.HookM (HookM)
import Jelly.Data.JellyM (JellyM)
import Jelly.Hooks.UseEffect (useEffect)
import Web.DOM (Node)
import Web.DOM.Document (createTextNode)
import Web.DOM.Node (setTextContent)
import Web.DOM.Text as Text
import Web.HTML (window)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.Window (document)

text :: forall m. MonadEffect m => JellyM m String -> HookM m Node
text strM = do
  node <- liftEffect $ Text.toNode <$>
    ( createTextNode "" <<< HTMLDocument.toDocument
        =<< document
        =<< window
    )

  useEffect do
    str <- strM
    liftEffect $ setTextContent str node
    pure $ pure unit

  pure node
