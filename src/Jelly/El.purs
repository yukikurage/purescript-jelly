module Jelly.El where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.Writer (tell)
import Data.Array (fold)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Class.Platform (class Browser)
import Jelly.Data.Component (Component, runComponent)
import Jelly.Data.Emitter (Emitter, addListener, emit, newEmitter)
import Jelly.Data.Instance (Instance, fromNode, newInstance, newTextInstance, setInnerHTML, setTextContent, updateChildren)
import Jelly.Data.Prop (Prop, registerProps)
import Jelly.Data.Signal (Signal, defer, launch, signalWithoutEq, writeAtom)
import Web.DOM (Element)
import Web.DOM.Element as Element

registerChildNodes :: Signal (Array Instance) -> Emitter -> Instance -> Effect Unit
registerChildNodes nodesSig unmountEmitter inst = addListener unmountEmitter =<< launch do
  nodes <- nodesSig
  liftEffect $ updateChildren nodes inst

-- | Create Element Component
el :: forall context. String -> Array Prop -> Component context -> Component context
el tag props component = do
  inst <- liftEffect $ newInstance tag

  internal <- ask

  liftEffect $ registerProps props internal.unmountEmitter inst

  childNodes <- liftEffect $ runComponent component internal
  liftEffect $ registerChildNodes childNodes internal.unmountEmitter inst

  tell $ pure [ inst ]

el_ :: forall context. String -> Component context -> Component context
el_ tag component = el tag [] component

-- | Element which innerHTML is given string
rawEl :: forall context. String -> Array Prop -> Signal String -> Component context
rawEl tag props htmlSig = do
  inst <- liftEffect $ newInstance tag

  internal <- ask

  liftEffect $ registerProps props internal.unmountEmitter inst

  liftEffect $ addListener internal.unmountEmitter =<< launch do
    html <- htmlSig
    liftEffect $ setInnerHTML html inst

  tell $ pure [ inst ]

registerText :: Signal String -> Emitter -> Instance -> Effect Unit
registerText value unmountEmitter inst =
  addListener unmountEmitter =<< launch do
    v <- value
    liftEffect $ setTextContent v inst

-- -- | Create Text Component
text :: forall context. Signal String -> Component context
text signal = do
  inst <- liftEffect $ newTextInstance ""

  internal <- ask

  liftEffect $ registerText signal internal.unmountEmitter inst

  tell $ pure [ inst ]

-- -- | Overwrite real Element
overwrite
  :: forall context
   . Browser
  => Array Prop
  -> Component context
  -> context
  -> Emitter
  -> Element
  -> Effect Unit
overwrite props component context unmountEmitter elem = do
  let
    inst = fromNode $ Element.toNode elem

  registerProps props unmountEmitter inst

  childNodes <- liftEffect $ runComponent component { unmountEmitter, context }
  liftEffect $ registerChildNodes childNodes unmountEmitter inst

-- -- | Fold Components
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

-- TODO
-- forC
--   :: forall context a key
--    . Ord key
--   => Eq a
--   => (a -> key)
--   -> Signal (Array a)
--   -> (Signal a -> Component context)
--   -> Component context
