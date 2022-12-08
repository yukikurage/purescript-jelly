module Jelly.Hydrate
  ( HydrateM(..)
  , hydrate
  , mount
  ) where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, class MonadTrans, ReaderT, ask, lift, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.Writer (class MonadTell, class MonadWriter, WriterT, runWriterT, tell)
import Control.Safely (for_, traverse_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (Ref, new, read, write)
import Jelly.Component (Component, ComponentF(..), foldComponentM)
import Jelly.Hooks (class MonadHooks, useEvent, useHooks, useHooks_, useUpdate)
import Jelly.Prop (Prop(..))
import Jelly.Signal (Signal, readSignal)
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

runSignalRegister :: forall m. MonadHooks m => Boolean -> Signal (m Unit) -> m Unit
runSignalRegister doInitialize = if doInitialize then useHooks_ else useUpdate

useRegisterProp :: forall m. MonadHooks m => Boolean -> Element -> Prop m -> m Unit
useRegisterProp doInitialize element = case _ of
  PropAttribute name valueSig -> runSignalRegister doInitialize $ valueSig <#> \value -> liftEffect do
    case value of
      Nothing -> removeAttribute name element
      Just v -> setAttribute name v element
  PropHandler eventType handler -> do
    useEvent (Element.toEventTarget element) eventType handler
  PropMountEffect effect -> do
    effect element

useRegisterProps :: forall m. MonadHooks m => MonadRec m => Boolean -> Element -> Array (Prop m) -> m Unit
useRegisterProps doInitialize element props = traverse_ (useRegisterProp doInitialize element) props

useRegisterChildren :: forall m. MonadHooks m => Boolean -> Node -> Signal (Array Node) -> m Unit
useRegisterChildren doInitialize elem chlSig = runSignalRegister doInitialize $ chlSig <#> \chl -> liftEffect $ updateChildren elem chl

useRegisterText :: forall m. MonadHooks m => Boolean -> Text -> Signal String -> m Unit
useRegisterText doInitialize txt txtSig =
  runSignalRegister doInitialize $ txtSig <#> \tx -> liftEffect $ setTextContent tx $ Text.toNode txt

-- | Monad for hydrating a component.
-- | Ref (Maybe Node) is used to store the existing DOM node.
-- | Signal (Array Node) are result nodes.
newtype HydrateM m a = HydrateM (ReaderT (Ref (Maybe Node)) (WriterT (Signal (Array Node)) m) a)

derive newtype instance Functor m => Functor (HydrateM m)
derive newtype instance Monad m => Apply (HydrateM m)
derive newtype instance Monad m => Applicative (HydrateM m)
derive newtype instance Monad m => Bind (HydrateM m)
derive newtype instance Monad m => Monad (HydrateM m)
derive newtype instance MonadEffect m => MonadEffect (HydrateM m)
derive newtype instance MonadRec m => MonadRec (HydrateM m)
derive newtype instance Monad m => MonadTell (Signal (Array Node)) (HydrateM m)
derive newtype instance Monad m => MonadWriter (Signal (Array Node)) (HydrateM m)
derive newtype instance Monad m => MonadAsk (Ref (Maybe Node)) (HydrateM m)
derive newtype instance Monad m => MonadReader (Ref (Maybe Node)) (HydrateM m)
derive newtype instance MonadHooks m => MonadHooks (HydrateM m)
instance MonadTrans HydrateM where
  lift = HydrateM <<< lift <<< lift

runHydrateM :: forall m a. Monad m => HydrateM m a -> Ref (Maybe Node) -> m (a /\ Signal (Array Node))
runHydrateM (HydrateM m) ref = runWriterT $ runReaderT m ref

hydrateNode
  :: forall m a
   . MonadEffect m
  => (Node -> Maybe a)
  -> (a -> Node)
  -> Effect a
  -> HydrateM m (a /\ Boolean)
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

hydrateInterpreter
  :: forall m
   . Monad m
  => MonadRec m
  => MonadHooks m
  => ComponentF m ~> HydrateM m
hydrateInterpreter componentF = do
  w <- liftEffect window
  d <- liftEffect $ HTMLDocument.toDocument <$> document w
  case componentF of
    ComponentEl tag props children f -> do
      e /\ isHydrate <- hydrateNode Element.fromNode Element.toNode $ createElement tag d

      lift $ hydrate children $ Element.toNode e
      lift $ useRegisterProps (not isHydrate) e props

      pure f
    ComponentElNS namespace tag props children f -> do
      el /\ isHydrate <- hydrateNode Element.fromNode Element.toNode $ createElementNS (Just namespace) tag d

      lift $ hydrate children $ Element.toNode el
      lift $ useRegisterProps (not isHydrate) el props

      pure f
    ComponentElVoid tag props f -> do
      el /\ isHydrate <- hydrateNode Element.fromNode Element.toNode $ createElement tag d

      lift $ useRegisterProps (not isHydrate) el props

      pure f
    ComponentTextSig ts f -> do
      txt /\ isHydrate <- hydrateNode Text.fromNode Text.toNode (createTextNode "" d)

      lift $ useRegisterText (not isHydrate) txt ts

      pure f
    ComponentRawSig innerHtmlSig f -> do
      realNodeRef <- ask
      nodesSig <- lift $ useHooks $ liftEffect <<< convertInnerHtmlToNodes <$> innerHtmlSig
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

      pure f
    ComponentDoctype name publicId systemId f -> do
      _ <- hydrateNode DocumentType.fromNode DocumentType.toNode
        (createDocumentType name publicId systemId d)

      pure f
    ComponentHooks (hooks :: m (Component m)) f -> do
      foldComponentM hydrateInterpreter =<< lift hooks

      pure f
    ComponentSwitch (signal :: Signal (Component m)) f -> do
      useHooks_ $ foldComponentM hydrateInterpreter <$> signal

      pure f

-- | Hydrate a component into a DOM node.
-- | Nodes must be in the same order as the component.
hydrate :: forall m. MonadHooks m => MonadRec m => Component m -> Node -> m Unit
hydrate component node = do
  realNodeRef <- liftEffect $ new =<< firstChild node
  _ /\ nodesSig <- runHydrateM (foldComponentM hydrateInterpreter component) realNodeRef
  useRegisterChildren true node nodesSig

-- | Mount a component into a DOM node.
-- | Existing nodes will be removed.
mount :: forall m. MonadHooks m => MonadRec m => Component m -> Node -> m Unit
mount cmp node = do
  liftEffect $ updateChildren node []
  hydrate cmp node
