module Jelly.El where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.Writer (tell)
import Data.Array (fold)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Component (Component, runComponent)
import Jelly.Data.Emitter (Emitter, addListener, emit, newEmitter)
import Jelly.Data.Prop (Prop, registerProps)
import Jelly.Data.Signal (Signal, defer, launch, signalWithoutEq, writeAtom)
import Web.DOM (Element, Node, Text)
import Web.DOM.Document (createElement, createTextNode)
import Web.DOM.Element as Element
import Web.DOM.Node (setTextContent)
import Web.DOM.Text as Text
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

foreign import updateChildNodes :: Array Node -> Node -> Effect Unit

registerChildNodes :: Signal (Array Node) -> Emitter -> Node -> Effect Unit
registerChildNodes nodesSig unmountEmitter parentNode = addListener unmountEmitter =<< launch do
  nodes <- nodesSig
  liftEffect $ updateChildNodes nodes parentNode

-- | Create Element Component
el :: forall context. String -> Array Prop -> Component context -> Component context
el tag props component = do
  elem <- liftEffect $ createElement tag <<< toDocument =<< document =<< window

  internal <- ask

  liftEffect $ registerProps props internal.unmountEmitter elem

  childNodes <- liftEffect $ runComponent component internal
  liftEffect $ registerChildNodes childNodes internal.unmountEmitter $ Element.toNode elem

  tell $ pure [ Element.toNode elem ]

el_ :: forall context. String -> Component context -> Component context
el_ tag component = el tag [] component

registerText :: Signal String -> Emitter -> Text -> Effect Unit
registerText value unmountEmitter tx =
  addListener unmountEmitter =<< launch do
    v <- value
    liftEffect $ setTextContent v (Text.toNode tx)

-- | Create Text Component
text :: forall context. Signal String -> Component context
text signal = do
  tx <- liftEffect $ createTextNode "" <<< toDocument =<< document =<< window

  internal <- ask

  liftEffect $ registerText signal internal.unmountEmitter tx

  tell $ pure [ Text.toNode tx ]

-- | Overwrite real Element
overwrite
  :: forall context. Array Prop -> Component context -> context -> Emitter -> Element -> Effect Unit
overwrite props component context unmountEmitter elem = do
  registerProps props unmountEmitter elem

  childNodes <- liftEffect $ runComponent component { unmountEmitter, context }
  liftEffect $ registerChildNodes childNodes unmountEmitter $ Element.toNode elem

-- | Embed real Node to Component
embedNode :: forall context. Node -> Component context
embedNode node = tell $ pure [ node ]

-- | Fold Components
fragment :: forall context. Array (Component context) -> Component context
fragment = fold

signalC :: forall context. Signal (Component context) -> Component context
signalC cmpSig = do
  { context, unmountEmitter } <- ask

  nodesSig /\ nodesAtom <- signalWithoutEq $ pure []

  liftEffect $ addListener unmountEmitter =<< launch do
    cmp <- cmpSig
    ue <- liftEffect newEmitter
    cmpNodes <- liftEffect $ runComponent cmp { unmountEmitter: ue, context }
    writeAtom nodesAtom cmpNodes
    defer $ emit ue
  tell $ join nodesSig

ifC
  :: forall context. Signal Boolean -> Component context -> Component context -> Component context
ifC blSig thenComponent elseComponent = signalC do
  bl <- blSig
  pure $ if bl then thenComponent else elseComponent

-- | Create empty Component
emptyC :: forall context. Component context
emptyC = mempty

whenC :: forall context. Signal Boolean -> Component context -> Component context
whenC blSig component = ifC blSig component emptyC

-- forC
--   :: forall context a key
--    . Ord key
--   => Eq a
--   => (a -> key)
--   -> Signal (Array a)
--   -> (Signal a -> Component context)
--   -> Component context