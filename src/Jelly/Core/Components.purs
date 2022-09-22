module Jelly.Core.Components where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.Writer (tell)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (read, write)
import Jelly.Core.Data.Component (Component, ComponentM, runComponent, tellInstancesSig, tellUnmountEffect)
import Jelly.Core.Data.Instance (Instance, newDocTypeInstance, newInstance, newInstanceNS, newTextInstance, nextSibling)
import Jelly.Core.Data.Prop (Prop)
import Jelly.Core.Data.Signal (Signal, defer, launch, signalWithoutEq, writeAtom)
import Jelly.Core.Register (registerChildComponent, registerInnerHtml, registerProps, registerText)
import Prim.Row (class Union)
import Record (union)

-- | Use real instance if it exits
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

  { context } <- ask

  tellUnmountEffect =<< liftEffect (registerProps inst props)
  tellUnmountEffect =<< liftEffect (registerChildComponent inst childComponent context)

  tellInstancesSig $ pure [ inst ]

el_ :: forall context. String -> Component context -> Component context
el_ tag component = el tag [] component

elNS
  :: forall context
   . String
  -> String
  -> Array Prop
  -> ComponentM context Unit
  -> ComponentM context Unit
elNS nameSpaceURI tag props childComponent = do
  inst <- hydrateInstance $ newInstanceNS nameSpaceURI tag

  { context } <- ask

  tellUnmountEffect =<< liftEffect (registerProps inst props)
  tellUnmountEffect =<< liftEffect (registerChildComponent inst childComponent context)

  tellInstancesSig $ pure [ inst ]

elNS_ :: forall context. String -> String -> ComponentM context Unit -> ComponentM context Unit
elNS_ nameSpaceURI tag component = elNS nameSpaceURI tag [] component

-- | Element which innerHTML is given string
rawEl :: forall context. String -> Array Prop -> Signal String -> Component context
rawEl tag props htmlSig = do
  inst <- hydrateInstance $ newInstance tag

  tellUnmountEffect =<< liftEffect (registerProps inst props)
  tellUnmountEffect =<< liftEffect (registerInnerHtml inst htmlSig)

  tellInstancesSig $ pure [ inst ]

rawEl_ :: forall context. String -> Signal String -> Component context
rawEl_ tag htmlSig = rawEl tag [] htmlSig

-- | Create Text Component
text :: forall context. Signal String -> Component context
text signal = do
  inst <- hydrateInstance $ newTextInstance ""

  tellUnmountEffect =<< liftEffect (registerText inst signal)

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
