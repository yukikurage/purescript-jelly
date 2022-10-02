module Jelly.Core.Mount where

import Prelude

import Control.Monad.Writer (WriterT, runWriterT, tell)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Core.Data.Component (Component, ComponentF(..), foldComponent)
import Jelly.Core.Data.Signal (Signal, launch, send, signal)
import Jelly.Core.Register (registerChildren, registerInnerHtml, registerProps, registerText)
import Web.DOM (Document, DocumentType, Node)
import Web.DOM.Document (createElement, createTextNode)
import Web.DOM.DocumentType as DocumentType
import Web.DOM.Element as Element
import Web.DOM.Text as Text
import Web.HTML (window)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.Window (document)

foreign import createDocumentType
  :: String -> String -> String -> Document -> Effect DocumentType

-- | Component を node の 列の Signal に変換
-- | realNodeRef : Hydration するときに使う
makeNodesSig
  :: forall context
   . Record context
  -> Component context
  -> Effect { onUnmount :: Effect Unit, nodesSig :: Signal (Array Node) }
makeNodesSig ctx cmp = do
  w <- window
  d <- HTMLDocument.toDocument <$> document w

  let
    interpreter
      :: forall a
       . ComponentF context a
      -> WriterT ({ onUnmount :: Effect Unit, nodesSig :: Signal (Array Node) }) Effect a
    interpreter = case _ of
      ComponentElement { tag, props, children } free -> do
        el <- liftEffect $ createElement tag d

        { onUnmount: onu, nodesSig: nds } <- liftEffect $ makeNodesSig ctx children

        unRegisterProps <- liftEffect $ registerProps el props
        unRegisterChildren <- liftEffect $ registerChildren (Element.toNode el) nds

        let
          onUnmount = do
            unRegisterProps
            unRegisterChildren
            onu

        tell { onUnmount, nodesSig: pure [ Element.toNode el ] }

        pure free
      ComponentVoidElement { tag, props } free -> do
        el <- liftEffect $ createElement tag d

        unRegisterProps <- liftEffect $ registerProps el props

        let
          onUnmount = unRegisterProps

        tell { onUnmount, nodesSig: pure [ Element.toNode el ] }

        pure free
      ComponentText textSig free -> do
        txt <- liftEffect $ createTextNode "" d

        unRegisterText <- liftEffect $ registerText txt textSig

        let
          onUnmount = unRegisterText

        tell { onUnmount, nodesSig: pure [ Text.toNode txt ] }

        pure free
      ComponentRawElement { tag, props, innerHtml } free -> do
        el <- liftEffect $ createElement tag d

        unRegisterProps <- liftEffect $ registerProps el props
        unRegisterInnerHtml <- liftEffect $ registerInnerHtml el innerHtml

        let
          onUnmount = do
            unRegisterProps
            unRegisterInnerHtml

        tell { onUnmount, nodesSig: pure [ Element.toNode el ] }

        pure free
      ComponentDocType { name, publicId, systemId } free -> do
        docType <- liftEffect $ createDocumentType name publicId systemId d

        tell { onUnmount: mempty, nodesSig: pure [ DocumentType.toNode docType ] }

        pure free
      ComponentSignal cmpSig free -> do
        nodesSig /\ nodesAtom <- signal $ pure []

        unListen <- launch $ cmpSig <#> \c -> do
          { onUnmount: onu, nodesSig: nds } <- makeNodesSig ctx c
          send nodesAtom nds
          pure $ onu

        tell { onUnmount: unListen, nodesSig: join nodesSig }

        pure free
      ComponentLifeCycle eff free -> do
        { component: cmpL, onUnmount: onuL } <- liftEffect $ eff ctx

        { onUnmount: onu, nodesSig: nds } <- liftEffect $ makeNodesSig ctx cmpL

        tell { onUnmount: onuL <> onu, nodesSig: nds }

        pure free
  _ /\ { onUnmount, nodesSig } <- runWriterT $ foldComponent interpreter cmp

  pure { onUnmount, nodesSig }

mount
  :: forall context. Record context -> Component context -> Node -> Effect (Effect Unit)
mount ctx cmp node = do
  { onUnmount, nodesSig } <- makeNodesSig ctx cmp

  unRegisterChildren <- registerChildren node nodesSig
  pure $ onUnmount *> unRegisterChildren

mount_ :: forall context. Record context -> Component context -> Node -> Effect Unit
mount_ ctx cmp node = void $ mount ctx cmp node
