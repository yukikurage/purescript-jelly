module Jelly.Hydrate where

import Prelude

import Control.Monad.Writer (WriterT, runWriterT, tell)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (Ref, new, read, write)
import Jelly.Data.Component (Component, ComponentF(..), foldComponent)
import Jelly.Data.Signal (Signal, launch, send, signal)
import Jelly.Register (registerChildren, registerInnerHtml, registerProps, registerPropsWithoutInit, registerText)
import Web.DOM (Document, DocumentType, Node)
import Web.DOM.Document (createElement, createTextNode)
import Web.DOM.DocumentType as DocumentType
import Web.DOM.Element as Element
import Web.DOM.Node (firstChild, nextSibling)
import Web.DOM.Text as Text
import Web.HTML (window)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.Window (document)

foreign import createDocumentType
  :: String -> String -> String -> Document -> Effect DocumentType

-- | Component を node の 列の Signal に変換
-- | realNodeRef : Hydration するときに使う
hydrateNodesSig
  :: forall context
   . Ref (Maybe Node)
  -> Record context
  -> Component context
  -> Effect { onUnmount :: Effect Unit, nodesSig :: Signal (Array Node) }
hydrateNodesSig realNodeRef ctx cmp = do
  w <- window
  d <- HTMLDocument.toDocument <$> document w
  let
    hydrateNode
      :: forall a
       . (Node -> Maybe a)
      -> Effect a
      -> Effect (a /\ Boolean)
    hydrateNode convert make = do
      maybeNode <- read realNodeRef
      case maybeNode of
        Just node | Just a <- convert node -> do
          ns <- nextSibling node
          write ns realNodeRef
          pure $ a /\ true
        _ -> do
          a <- make
          pure $ a /\ false

    interpreter
      :: forall a
       . ComponentF context a
      -> WriterT ({ onUnmount :: Effect Unit, nodesSig :: Signal (Array Node) }) Effect a
    interpreter = case _ of
      ComponentElement { tag, props, children } free -> do
        el /\ isHydrate <- liftEffect $ hydrateNode Element.fromNode (createElement tag d)

        rnr <- liftEffect $ new <=< firstChild $ Element.toNode el
        { onUnmount: onu, nodesSig: nds } <- liftEffect $ hydrateNodesSig rnr ctx children

        unRegisterChildren <- liftEffect $ registerChildren (Element.toNode el) nds
        unRegisterProps <- liftEffect $
          if isHydrate then registerPropsWithoutInit el props else registerProps el props

        let
          onUnmount = do
            unRegisterProps
            unRegisterChildren
            onu

        tell { onUnmount, nodesSig: pure [ Element.toNode el ] }

        pure free
      ComponentVoidElement { tag, props } free -> do
        el /\ isHydrate <- liftEffect $ hydrateNode Element.fromNode (createElement tag d)

        unRegisterProps <- liftEffect $
          if isHydrate then registerPropsWithoutInit el props else registerProps el props

        let
          onUnmount = unRegisterProps

        tell { onUnmount, nodesSig: pure [ Element.toNode el ] }

        pure free
      ComponentText textSig free -> do
        txt /\ _ <- liftEffect $ hydrateNode Text.fromNode (createTextNode "" d)

        unRegisterText <- liftEffect $ registerText txt textSig

        let
          onUnmount = unRegisterText

        tell { onUnmount, nodesSig: pure [ Text.toNode txt ] }

        pure free
      ComponentRawElement { tag, props, innerHtml } free -> do
        el /\ isHydrate <- liftEffect $ hydrateNode Element.fromNode (createElement tag d)

        unRegisterInnerHtml <- liftEffect $ registerInnerHtml el innerHtml
        unRegisterProps <- liftEffect $
          if isHydrate then registerPropsWithoutInit el props else registerProps el props

        let
          onUnmount = do
            unRegisterProps
            unRegisterInnerHtml

        tell { onUnmount, nodesSig: pure [ Element.toNode el ] }

        pure free
      ComponentDocType { name, publicId, systemId } free -> do
        dt /\ _ <- liftEffect $ hydrateNode DocumentType.fromNode
          (createDocumentType name publicId systemId d)

        tell { onUnmount: mempty, nodesSig: pure [ DocumentType.toNode dt ] }

        pure free
      ComponentSignal cmpSig free -> do
        nodesSig /\ nodesAtom <- signal $ pure []

        unListen <- launch $ cmpSig <#> \c -> do
          { onUnmount: onu, nodesSig: nds } <- hydrateNodesSig realNodeRef ctx c
          send nodesAtom nds
          pure $ onu

        tell { onUnmount: unListen, nodesSig: join nodesSig }

        pure free
      ComponentLifeCycle eff free -> do
        { component: cmpL, onUnmount: onuL } <- liftEffect $ eff ctx

        { onUnmount: onu, nodesSig: nds } <- liftEffect $ hydrateNodesSig realNodeRef ctx cmpL

        tell { onUnmount: onuL *> onu, nodesSig: nds }

        pure free

  _ /\ { onUnmount, nodesSig } <- runWriterT $ foldComponent interpreter cmp

  pure { onUnmount, nodesSig }

hydrate
  :: forall context. Record context -> Component context -> Node -> Effect (Effect Unit)
hydrate ctx cmp node = do
  realNodeRef <- new =<< firstChild node
  { onUnmount, nodesSig } <- hydrateNodesSig realNodeRef ctx cmp
  unRegisterChildren <- registerChildren node nodesSig
  pure $ onUnmount *> unRegisterChildren

hydrate_
  :: forall context. Record context -> Component context -> Node -> Effect Unit
hydrate_ ctx cmp node = void $ hydrate ctx cmp node