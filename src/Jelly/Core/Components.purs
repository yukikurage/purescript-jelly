module Jelly.Core.Components where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.Writer (tell)
import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Core.Data.Component (Component, ComponentM, runComponent, tellInstancesSig, tellUnmountEffect)
import Jelly.Core.Data.Instance (Instance, addEventListener, firstChild, newDocTypeInstance, newInstance, newTextInstance, nextSibling, removeAttribute, setAttribute, setInnerHTML, setTextContent, updateChildren)
import Jelly.Core.Data.Prop (Prop(..))
import Jelly.Core.Data.Signal (Signal, defer, launch, signalWithoutEq, writeAtom)
import Prim.Row (class Union)
import Record (union)

registerChildComponent :: forall context. Instance -> Component context -> Component context
registerChildComponent inst childComponent = do
  { context } <- ask

  realInstanceRef <- liftEffect $ new =<< firstChild inst

  { instancesSig, unmountEffect } <- liftEffect $ runComponent childComponent
    { context, realInstanceRef }

  liftEffect $ write Nothing realInstanceRef

  stop <- launch do
    instances <- instancesSig
    liftEffect $ updateChildren instances inst

  tellUnmountEffect stop
  tellUnmountEffect unmountEffect

registerProps :: forall context. Instance -> Array Prop -> Component context
registerProps inst props = do
  for_ props \prop -> case prop of
    PropAttribute key valueSig -> do
      stop <- launch do
        valueMaybe <- valueSig
        liftEffect case valueMaybe of
          Just value -> setAttribute key value inst
          Nothing -> removeAttribute key inst

      tellUnmountEffect stop

    PropHandler eventType listener -> do
      stop <- liftEffect $ addEventListener eventType listener inst

      tellUnmountEffect stop

registerText :: forall context. Instance -> Signal String -> Component context
registerText inst valueSig = do
  stop <- launch do
    value <- valueSig
    liftEffect $ setTextContent value inst

  tellUnmountEffect stop

registerInnerHtml :: forall context. Instance -> Signal String -> Component context
registerInnerHtml inst htmlSig = do
  stop <- launch do
    html <- htmlSig
    liftEffect $ setInnerHTML html inst

  tellUnmountEffect stop

hydrateInstance :: forall context. Effect Instance -> ComponentM context Instance
hydrateInstance mkInst = do
  { realInstanceRef } <- ask
  liftEffect do
    realInstanceMaybe <- read realInstanceRef

    case realInstanceMaybe of
      Just realInstance -> do
        ns <- nextSibling realInstance
        write ns realInstanceRef
        pure realInstance
      Nothing -> mkInst

-- | Create Element Component
el :: forall context. String -> Array Prop -> Component context -> Component context
el tag props childComponent = do
  inst <- hydrateInstance $ newInstance tag

  registerProps inst props
  registerChildComponent inst childComponent

  tellInstancesSig $ pure [ inst ]

el_ :: forall context. String -> Component context -> Component context
el_ tag component = el tag [] component

-- | Element which innerHTML is given string
rawEl :: forall context. String -> Array Prop -> Signal String -> Component context
rawEl tag props htmlSig = do
  inst <- hydrateInstance $ newInstance tag

  registerProps inst props
  registerInnerHtml inst htmlSig

  tellInstancesSig $ pure [ inst ]

rawEl_ :: forall context. String -> Signal String -> Component context
rawEl_ tag htmlSig = rawEl tag [] htmlSig

-- | Create Text Component
text :: forall context. Signal String -> Component context
text signal = do
  inst <- hydrateInstance $ newTextInstance ""

  registerText inst signal

  tellInstancesSig $ pure [ inst ]

docType :: forall context. String -> String -> String -> Component context
docType qualifiedName publicId systemId = do
  inst <- hydrateInstance $ newDocTypeInstance qualifiedName publicId systemId

  tellInstancesSig $ pure [ inst ]

docTypeHTML :: forall context. ComponentM context Unit
docTypeHTML = docType "html" "" ""

signalC :: forall context. Signal (Component context) -> Component context
signalC componentSig = do
  internalR <- ask

  nodesSig /\ nodesAtom <- signalWithoutEq $ pure []

  stop <- launch do
    component <- componentSig
    { unmountEffect, instancesSig } <- liftEffect $ runComponent component internalR
    writeAtom nodesAtom instancesSig
    defer unmountEffect

  tellUnmountEffect stop
  tellInstancesSig $ join nodesSig

ifC
  :: forall context. Signal Boolean -> Component context -> Component context -> Component context
ifC blSig thenComponent elseComponent = signalC do
  bl <- blSig
  pure $ if bl then thenComponent else elseComponent

whenC :: forall context. Signal Boolean -> Component context -> Component context
whenC blSig component = ifC blSig component mempty

contextC :: forall context. (Record context -> Component context) -> Component context
contextC component = do
  { context } <- ask
  component context

contextProvider
  :: forall oldContext appendContext newContext
   . Union appendContext oldContext newContext
  => Record appendContext
  -> Component newContext
  -> Component oldContext
contextProvider appendContext component = do
  { context, realInstanceRef } <- ask
  let newContext = union appendContext context
  componentW <- liftEffect $ runComponent component
    { context: newContext, realInstanceRef }
  tell componentW

-- TODO
-- forC
--   :: forall context a key
--    . Ord key
--   => Eq a
--   => (a -> key)
--   -> Signal (Array a)
--   -> (Signal a -> Component context)
--   -> Component context
