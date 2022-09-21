module Jelly.El where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.Writer (tell)
import Control.Safely (for_)
import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Data.Component (Component, ComponentM, runComponent)
import Jelly.Data.Emitter (Emitter, addListener, emit, newEmitter)
import Jelly.Data.Instance (Instance, addEventListener, firstChild, newDocTypeInstance, newInstance, newTextInstance, nextSibling, removeAttribute, setAttribute, setInnerHTML, setTextContent, updateChildren)
import Jelly.Data.Prop (Prop(..))
import Jelly.Data.Signal (Signal, defer, launch, readSignal, signalWithoutEq, writeAtom)
import Prim.Row (class Union)
import Record (union)

registerChildNodes
  :: forall context
   . Boolean
  -> Component context
  -> Record context
  -> Emitter
  -> Instance
  -> Effect Unit
registerChildNodes isFirstRun component context unmountEmitter inst = do
  fc <- firstChild inst
  fcRef <- new fc
  nodesSig <- runComponent component $ { realInstanceRef: fcRef, unmountEmitter, context }
  write Nothing fcRef

  isFirstRef <- new true

  stop <- launch do
    nodes <- nodesSig
    liftEffect do
      isFirst <- read isFirstRef
      when (isFirstRun || not isFirst) $ updateChildren nodes inst
      write false isFirstRef
  addListener unmountEmitter stop

registerProps
  :: forall context
   . Boolean
  -> Array (Prop context)
  -> Record context
  -> Emitter
  -> Instance
  -> Effect Unit
registerProps isFirstRun props context unmountEmitter inst = do
  isFirstRef <- new true
  for_ props case _ of
    PropAttribute name signal ->
      addListener unmountEmitter =<< launch do
        value <- signal context
        liftEffect do
          isFirst <- read isFirstRef
          when (isFirstRun || not isFirst) case value of
            Just v -> setAttribute name v inst
            Nothing -> removeAttribute name inst
          write false isFirstRef
    PropHandler eventType handler -> do
      remove <- addEventListener eventType (handler context) inst
      addListener unmountEmitter remove

registerText :: Boolean -> Signal String -> Emitter -> Instance -> Effect Unit
registerText isFirstRun valueSig unmountEmitter inst = do
  isFirstRef <- new true
  stop <- launch do
    value <- valueSig
    liftEffect do
      isFirst <- read isFirstRef
      when (isFirstRun || not isFirst) $ setTextContent value inst
      write false isFirstRef
  addListener unmountEmitter stop

registerInnerHtml :: Boolean -> Signal String -> Emitter -> Instance -> Effect Unit
registerInnerHtml isFirstRun htmlSig unmountEmitter inst = do
  isFirstRef <- new true
  stop <- launch do
    html <- htmlSig
    liftEffect do
      isFirst <- read isFirstRef
      when (isFirstRun || not isFirst) $ setInnerHTML html inst
      write false isFirstRef
  addListener unmountEmitter stop

-- | Create Element Component
el :: forall context. String -> Array (Prop context) -> Component context -> Component context
el tag props component = do
  { realInstanceRef, unmountEmitter, context } <- ask

  realInstMaybe <- liftEffect $ read realInstanceRef

  inst <- case realInstMaybe of
    Just realInst -> liftEffect $ do
      ns <- nextSibling realInst
      write ns realInstanceRef

      registerProps false props context unmountEmitter realInst

      registerChildNodes false component context unmountEmitter realInst

      pure realInst
    Nothing -> liftEffect $ do
      inst <- newInstance tag

      registerProps true props context unmountEmitter inst

      registerChildNodes true component context unmountEmitter inst

      pure inst

  tell $ pure [ inst ]

el_ :: forall context. String -> Component context -> Component context
el_ tag component = el tag [] component

-- | Element which innerHTML is given string
rawEl :: forall context. String -> Array (Prop context) -> Signal String -> Component context
rawEl tag props htmlSig = do
  { realInstanceRef, unmountEmitter, context } <- ask

  realInstMaybe <- liftEffect $ read realInstanceRef

  inst <- case realInstMaybe of
    Just realInst -> liftEffect $ do
      ns <- nextSibling realInst
      write ns realInstanceRef

      registerProps false props context unmountEmitter realInst

      registerInnerHtml false htmlSig unmountEmitter realInst

      pure realInst
    Nothing -> liftEffect $ do
      inst <- newInstance tag

      registerProps true props context unmountEmitter inst

      registerInnerHtml true htmlSig unmountEmitter inst

      pure inst

  tell $ pure [ inst ]

rawEl_ :: forall context. String -> Signal String -> Component context
rawEl_ tag htmlSig = rawEl tag [] htmlSig

-- | Create Text Component
text :: forall context. Signal String -> Component context
text signal = do
  { realInstanceRef, unmountEmitter } <- ask

  realInstMaybe <- liftEffect $ read realInstanceRef

  inst <- case realInstMaybe of
    Just realInst -> liftEffect $ do
      ns <- nextSibling realInst
      write ns realInstanceRef

      registerText false signal unmountEmitter realInst

      pure realInst
    Nothing -> liftEffect $ do
      inst <- newTextInstance =<< readSignal signal

      registerText true signal unmountEmitter inst

      pure inst

  tell $ pure [ inst ]

docType :: forall context. String -> String -> String -> Component context
docType qualifiedName publicId systemId = do
  { realInstanceRef } <- ask

  realInstMaybe <- liftEffect $ read realInstanceRef

  inst <- case realInstMaybe of
    Just realInst -> liftEffect $ do
      ns <- nextSibling realInst
      write ns realInstanceRef

      pure realInst
    Nothing -> liftEffect $ do
      inst <- newDocTypeInstance qualifiedName publicId systemId

      pure inst

  tell $ pure [ inst ]

docTypeHTML :: forall context. ComponentM context Unit
docTypeHTML = docType "html" "" ""

-- | Fold Components
fragment :: forall context. Array (Component context) -> Component context
fragment = fold

signalC :: forall context. Signal (Component context) -> Component context
signalC cmpSig = do
  { context, unmountEmitter, realInstanceRef } <- ask

  nodesSig /\ nodesAtom <- signalWithoutEq $ pure []

  liftEffect $ addListener unmountEmitter =<< launch do
    cmp <- cmpSig
    ue <- liftEffect newEmitter
    cmpNodes <- liftEffect $ runComponent cmp { unmountEmitter: ue, context, realInstanceRef }
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

contextC :: forall context. (Record context -> Component context) -> Component context
contextC component = do
  { context, unmountEmitter, realInstanceRef } <- ask
  instanceArraySig <- liftEffect $ runComponent (component context)
    { context, unmountEmitter, realInstanceRef }
  tell instanceArraySig

contextProvider
  :: forall oldContext appendContext newContext
   . Union appendContext oldContext newContext
  => Record appendContext
  -> Component newContext
  -> Component oldContext
contextProvider appendContext component = do
  { context, unmountEmitter, realInstanceRef } <- ask
  let newContext = union appendContext context
  instanceArraySig <- liftEffect $ runComponent component
    { context: newContext, unmountEmitter, realInstanceRef }
  tell instanceArraySig

-- TODO
-- forC
--   :: forall context a key
--    . Ord key
--   => Eq a
--   => (a -> key)
--   -> Signal (Array a)
--   -> (Signal a -> Component context)
--   -> Component context
