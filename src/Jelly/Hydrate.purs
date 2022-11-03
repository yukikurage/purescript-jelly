module Jelly.Hydrate where

import Prelude

import Control.Monad.Reader (ReaderT, ask, runReaderT)
import Control.Monad.Writer (WriterT, runWriterT, tell)
import Data.Foldable (for_, traverse_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (Ref, new, read, write)
import Jelly.Component (Component, ComponentF(..), runComponentM)
import Jelly.Prop (Prop(..))
import Signal (Signal, newState, readSignal, runSignal, watchSignal, writeChannel)
import Signal.Hooks (Hooks, liftHooks, useCleaner, useEvent, useHooks, useHooks_)
import Web.DOM (Document, DocumentType, Element, Node, Text)
import Web.DOM.Document (createElement, createElementNS, createTextNode)
import Web.DOM.DocumentType as DocumentType
import Web.DOM.Element (removeAttribute, setAttribute)
import Web.DOM.Element as Element
import Web.DOM.Node (firstChild, nextSibling, setTextContent)
import Web.DOM.Text as Text
import Web.HTML (window)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.Window (document)

foreign import createDocumentType
  :: String -> String -> String -> Document -> Effect DocumentType

foreign import convertInnerHtmlToNodes :: String -> Effect (Array Node)

foreign import updateChildren :: Node -> Array Node -> Effect Unit

runSignalRegister :: forall m. MonadEffect m => Boolean -> Signal (Effect (Effect Unit)) -> m (Effect Unit)
runSignalRegister doInitialize = if doInitialize then runSignal else watchSignal

useRegisterProp :: forall context. Boolean -> Element -> Prop context -> Hooks context Unit
useRegisterProp doInitialize element = case _ of
  PropAttribute name valueSig -> do
    cleaner <- runSignalRegister doInitialize $ valueSig <#> \value -> do
      case value of
        Nothing -> removeAttribute name element
        Just v -> setAttribute name v element
      mempty
    useCleaner cleaner
  PropHandler eventType handler -> do
    useEvent (Element.toEventTarget element) eventType handler
  PropMountEffect effect -> do
    effect element

useRegisterProps :: forall context. Boolean -> Element -> Array (Prop context) -> Hooks context Unit
useRegisterProps doInitialize element props = traverse_ (useRegisterProp doInitialize element) props

useRegisterChildren :: forall context. Boolean -> Node -> Signal (Array Node) -> Hooks context Unit
useRegisterChildren doInitialize elem chlSig = do
  cleaner <- runSignalRegister doInitialize $ chlSig <#> \chl -> do
    updateChildren elem chl
    mempty
  useCleaner cleaner

useRegisterText :: forall context. Boolean -> Text -> Signal String -> Hooks context Unit
useRegisterText doInitialize txt txtSig = do
  cleaner <- runSignalRegister doInitialize $
    txtSig <#> \tx -> do
      setTextContent tx $ Text.toNode txt
      mempty
  useCleaner cleaner

type HydrateM context a = ReaderT (Ref (Maybe Node)) (WriterT (Signal (Array Node)) (Hooks context)) a

hydrateNode
  :: forall context a
   . (Node -> Maybe a)
  -> (a -> Node)
  -> Effect a
  -> HydrateM context (a /\ Boolean)
hydrateNode convertTo convertFrom make = do
  realNodeRef <- ask
  maybeNode <- liftEffect $ read realNodeRef
  case maybeNode of
    Just node | Just a <- convertTo node -> do
      ns <- liftEffect $ nextSibling node
      liftEffect $ write ns realNodeRef
      tell $ pure [ node ]
      pure $ a /\ true
    _ -> do
      a <- liftEffect $ make
      tell $ pure [ convertFrom a ]
      pure $ a /\ false

hydrateInterpreter :: forall context. ComponentF context ~> HydrateM context
hydrateInterpreter cmp = do
  w <- liftEffect window
  d <- liftEffect $ HTMLDocument.toDocument <$> document w
  case cmp of
    ComponentElement { tag, props, children } free -> do
      el /\ isHydrate <- hydrateNode Element.fromNode Element.toNode $ createElement tag d

      liftHooks $ hydrate children $ Element.toNode el
      liftHooks $ useRegisterProps (not isHydrate) el props

      pure free
    ComponentElementNS { namespace, tag, props, children } free -> do
      el /\ isHydrate <- hydrateNode Element.fromNode Element.toNode $ createElementNS (Just namespace) tag d

      liftHooks $ hydrate children $ Element.toNode el
      liftHooks $ useRegisterProps (not isHydrate) el props

      pure free
    ComponentVoidElement { tag, props } free -> do
      el /\ isHydrate <- hydrateNode Element.fromNode Element.toNode $ createElement tag d

      liftHooks $ useRegisterProps (not isHydrate) el props

      pure free

    ComponentText textSig free -> do
      txt /\ isHydrate <- hydrateNode Text.fromNode Text.toNode (createTextNode "" d)

      liftHooks $ useRegisterText (not isHydrate) txt textSig

      pure free
    ComponentRaw innerHtmlSig free -> do
      realNodeRef <- ask
      nodesSig <- useHooks $ liftEffect <<< convertInnerHtmlToNodes <$> innerHtmlSig
      let
        skipRef = do
          maybeNode <- read realNodeRef
          case maybeNode of
            Just node -> do
              ns <- nextSibling node
              write ns realNodeRef
            Nothing -> write Nothing realNodeRef

      nodes <- readSignal nodesSig
      liftEffect $ for_ nodes \_ -> skipRef

      tell nodesSig

      pure free
    ComponentDocType { name, publicId, systemId } free -> do
      _ <- hydrateNode DocumentType.fromNode DocumentType.toNode
        (createDocumentType name publicId systemId d)

      pure free
    ComponentSignal cmpSig free -> do
      nodesSig /\ nodesChannel <- newState $ pure []
      realNodeRef <- ask

      useHooks_ $ cmpSig <#> \c -> do
        _ /\ nds <- runWriterT $ runReaderT (runComponentM hydrateInterpreter c) realNodeRef
        writeChannel nodesChannel nds

      tell $ join nodesSig

      pure free

hydrate
  :: forall context. Component context -> Node -> Hooks context Unit
hydrate cmp node = do
  realNodeRef <- liftEffect $ new =<< firstChild node
  _ /\ nodesSig <- runWriterT $ runReaderT (runComponentM hydrateInterpreter cmp) realNodeRef
  useRegisterChildren true node nodesSig

mount :: forall context. Component context -> Node -> Hooks context Unit
mount cmp node = do
  liftEffect $ updateChildren node []
  hydrate cmp node
