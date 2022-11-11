module Jelly.Hydrate where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.Writer (class MonadTell, class MonadWriter, WriterT, runWriterT, tell)
import Data.Foldable (for_, traverse_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (Ref, new, read, write)
import Jelly.Component (class Component)
import Jelly.Hooks (class MonadHooks, Hooks, liftHooks, useCleaner, useEvent, useHooks)
import Jelly.Prop (Prop(..))
import Jelly.Signal (Signal, readSignal, runSignal, watchSignal)
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

runSignalRegister :: forall m. MonadHooks m => MonadEffect m => Boolean -> Signal (Effect (Effect Unit)) -> m (Effect Unit)
runSignalRegister doInitialize = if doInitialize then runSignal else watchSignal

useRegisterProp :: forall m. MonadHooks m => Boolean -> Element -> Prop m -> m Unit
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

useRegisterProps :: forall m. MonadHooks m => Boolean -> Element -> Array (Prop m) -> m Unit
useRegisterProps doInitialize element props = traverse_ (useRegisterProp doInitialize element) props

useRegisterChildren :: forall m. MonadHooks m => Boolean -> Node -> Signal (Array Node) -> m Unit
useRegisterChildren doInitialize elem chlSig = do
  cleaner <- runSignalRegister doInitialize $ chlSig <#> \chl -> do
    updateChildren elem chl
    mempty
  useCleaner cleaner

useRegisterText :: forall m. MonadHooks m => Boolean -> Text -> Signal String -> m Unit
useRegisterText doInitialize txt txtSig = do
  cleaner <- runSignalRegister doInitialize $
    txtSig <#> \tx -> do
      setTextContent tx $ Text.toNode txt
      mempty
  useCleaner cleaner

newtype HydrateM a = HydrateM (ReaderT (Ref (Maybe Node)) (WriterT (Signal (Array Node)) Hooks) a)

derive newtype instance Functor HydrateM
derive newtype instance Apply HydrateM
derive newtype instance Applicative HydrateM
derive newtype instance Bind HydrateM
derive newtype instance Monad HydrateM
derive newtype instance MonadEffect HydrateM
derive newtype instance MonadRec HydrateM
derive newtype instance MonadTell (Signal (Array Node)) HydrateM
derive newtype instance MonadWriter (Signal (Array Node)) HydrateM
derive newtype instance MonadAsk (Ref (Maybe Node)) HydrateM
derive newtype instance MonadReader (Ref (Maybe Node)) HydrateM
derive newtype instance MonadHooks HydrateM

hydrateNode
  :: forall a
   . (Node -> Maybe a)
  -> (a -> Node)
  -> Effect a
  -> HydrateM (a /\ Boolean)
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

instance Component HydrateM where
  el tag props children = do
    w <- liftEffect window
    d <- liftEffect $ HTMLDocument.toDocument <$> document w
    e /\ isHydrate <- hydrateNode Element.fromNode Element.toNode $ createElement tag d

    liftHooks $ hydrate children $ Element.toNode e
    useRegisterProps (not isHydrate) e props

  elNS namespace tag props children = do
    w <- liftEffect window
    d <- liftEffect $ HTMLDocument.toDocument <$> document w
    el /\ isHydrate <- hydrateNode Element.fromNode Element.toNode $ createElementNS (Just namespace) tag d

    liftHooks $ hydrate children $ Element.toNode el
    useRegisterProps (not isHydrate) el props

  elVoid tag props = do
    w <- liftEffect window
    d <- liftEffect $ HTMLDocument.toDocument <$> document w
    el /\ isHydrate <- hydrateNode Element.fromNode Element.toNode $ createElement tag d

    useRegisterProps (not isHydrate) el props

  textSig ts = do
    w <- liftEffect window
    d <- liftEffect $ HTMLDocument.toDocument <$> document w
    txt /\ isHydrate <- hydrateNode Text.fromNode Text.toNode (createTextNode "" d)

    useRegisterText (not isHydrate) txt ts

  rawSig innerHtmlSig = do
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

  doctype name publicId systemId = do
    w <- liftEffect window
    d <- liftEffect $ HTMLDocument.toDocument <$> document w
    _ <- hydrateNode DocumentType.fromNode DocumentType.toNode
      (createDocumentType name publicId systemId d)

    pure unit

hydrate :: HydrateM Unit -> Node -> Hooks Unit
hydrate (HydrateM cmp) node = do
  realNodeRef <- liftEffect $ new =<< firstChild node
  _ /\ nodesSig <- runWriterT $ runReaderT cmp realNodeRef
  useRegisterChildren true node nodesSig

mount :: HydrateM Unit -> Node -> Hooks Unit
mount cmp node = do
  liftEffect $ updateChildren node []
  hydrate cmp node
