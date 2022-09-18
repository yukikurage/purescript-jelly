module Jelly.El where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.Writer (tell)
import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Data.String (toUpper)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Class.Platform (class Browser, runBrowserApp)
import Jelly.Data.Component (Component, ComponentM, runComponent)
import Jelly.Data.Emitter (Emitter, addListener, emit, newEmitter)
import Jelly.Data.Instance (Instance, fromNode, newDocTypeInstance, newInstance, newTextInstance, setInnerHTML, setTextContent, updateChildren)
import Jelly.Data.Instance as Instance
import Jelly.Data.Prop (Prop, registerProps)
import Jelly.Data.Signal (Signal, defer, launch, signalWithoutEq, writeAtom)
import Web.DOM (Node)
import Web.DOM.DocumentType as DocumentType
import Web.DOM.Element as Element
import Web.DOM.Node (firstChild, nextSibling)
import Web.DOM.Text as Text

registerChildNodes :: Signal (Array Instance) -> Emitter -> Instance -> Effect Unit
registerChildNodes nodesSig unmountEmitter inst = addListener unmountEmitter =<< launch do
  nodes <- nodesSig
  liftEffect $ updateChildren nodes inst

-- | realNode があったなら、それを使って Node を作ろうとする
newInstanceWithRealNode
  :: forall context. String -> ComponentM context (Instance /\ Maybe Node)
newInstanceWithRealNode tag = runBrowserApp do
  { realNodeRef } <- ask
  realNode <- liftEffect $ read realNodeRef
  case realNode of
    Just node | Just elem <- Element.fromNode node, Element.tagName elem == toUpper tag ->
      liftEffect $ do
        maybeNextNode <- nextSibling node
        write maybeNextNode realNodeRef
        maybeFc <- firstChild node
        pure $ Instance.fromNode node /\ maybeFc
    _ -> liftEffect do
      inst <- newInstance tag
      pure $ inst /\ Nothing

newTextInstanceWithRealNode :: forall context. String -> ComponentM context Instance
newTextInstanceWithRealNode txt = runBrowserApp do
  { realNodeRef } <- ask
  realNode <- liftEffect $ read realNodeRef
  case realNode of
    Just node | Just _ <- Text.fromNode node -> liftEffect $ do
      maybeNextNode <- nextSibling node
      write maybeNextNode realNodeRef
      pure $ Instance.fromNode node
    _ -> liftEffect $ newTextInstance txt

newDocTypeInstanceWithRealNode
  :: forall context. String -> String -> String -> ComponentM context Instance
newDocTypeInstanceWithRealNode qualifiedName publicId systemId = runBrowserApp do
  { realNodeRef } <- ask
  realNode <- liftEffect $ read realNodeRef
  case realNode of
    Just node | Just _ <- DocumentType.fromNode node -> liftEffect $ do
      maybeNextNode <- nextSibling node
      write maybeNextNode realNodeRef
      pure $ Instance.fromNode node
    _ -> liftEffect $ newDocTypeInstance qualifiedName publicId systemId

-- | Create Element Component
el :: forall context. String -> Array Prop -> Component context -> Component context
el tag props component = do
  inst /\ fc <- newInstanceWithRealNode tag

  internal <- ask

  liftEffect $ registerProps props internal.unmountEmitter inst

  realNodeRef <- liftEffect $ new fc

  childNodes <- liftEffect $ runComponent component $ internal { realNodeRef = realNodeRef }
  liftEffect $ registerChildNodes childNodes internal.unmountEmitter inst

  liftEffect $ write Nothing realNodeRef

  tell $ pure [ inst ]

el_ :: forall context. String -> Component context -> Component context
el_ tag component = el tag [] component

-- | Element which innerHTML is given string
rawEl :: forall context. String -> Array Prop -> Signal String -> Component context
rawEl tag props htmlSig = do
  inst /\ _ <- newInstanceWithRealNode tag

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

-- | Create Text Component
text :: forall context. Signal String -> Component context
text signal = do
  inst <- newTextInstanceWithRealNode ""

  internal <- ask

  liftEffect $ registerText signal internal.unmountEmitter inst

  tell $ pure [ inst ]

docType :: forall context. String -> String -> String -> Component context
docType qualifiedName publicId systemId = do
  inst <- newDocTypeInstanceWithRealNode qualifiedName publicId systemId

  tell $ pure [ inst ]

docTypeHTML :: forall context. ComponentM context Unit
docTypeHTML = docType "html" "" ""

-- -- | Overwrite real Node
overwrite
  :: forall context
   . Browser
  => Component context
  -> context
  -> Emitter
  -> Node
  -> Effect Unit
overwrite component context unmountEmitter node = do
  let
    inst = fromNode node

  realNodeRef <- liftEffect $ new =<< firstChild node

  childNodes <- liftEffect $ runComponent component { unmountEmitter, context, realNodeRef }
  liftEffect $ registerChildNodes childNodes unmountEmitter inst

-- | Fold Components
fragment :: forall context. Array (Component context) -> Component context
fragment = fold

signalC :: forall context. Signal (Component context) -> Component context
signalC cmpSig = do
  { context, unmountEmitter, realNodeRef } <- ask

  nodesSig /\ nodesAtom <- signalWithoutEq $ pure []

  liftEffect $ addListener unmountEmitter =<< launch do
    cmp <- cmpSig
    ue <- liftEffect newEmitter
    cmpNodes <- liftEffect $ runComponent cmp { unmountEmitter: ue, context, realNodeRef }
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
