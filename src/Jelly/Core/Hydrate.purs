module Jelly.Core.Hydrate where

import Prelude

import Control.Monad.Error.Class (throwError)
import Control.Monad.Writer (WriterT, runWriterT, tell)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Exception (error)
import Effect.Ref (Ref, new, read, write)
import Jelly.Core.Data.Component (Component, ComponentF(..), foldComponent)
import Jelly.Core.Data.Signal (Signal, launch, send, signal)
import Jelly.Core.Register (registerChildren, registerInnerHtml, registerPropsWithoutInit, registerText)
import Web.DOM (Node)
import Web.DOM.DocumentType as DocumentType
import Web.DOM.Element as Element
import Web.DOM.Node (firstChild, nextSibling)
import Web.DOM.Text as Text

hydrateNode :: forall a. Ref (Maybe Node) -> (Node -> Maybe a) -> String -> Effect a
hydrateNode ref convert name = do
  maybeNode <- read ref
  case maybeNode of
    Just node | Just a <- convert node -> do
      ns <- nextSibling node
      write ns ref
      pure a
    _ -> throwError $ error $ "Cannot hydrate " <> name <>
      " because there are no more nodes"

-- | Component を node の 列の Signal に変換
-- | realNodeRef : Hydration するときに使う
hydrateNodesSig
  :: forall context
   . Ref (Maybe Node)
  -> Record context
  -> Component context
  -> Effect { onUnmount :: Effect Unit, nodesSig :: Signal (Array Node) }
hydrateNodesSig realNodeRef ctx cmp = do
  let
    interpreter
      :: forall a
       . ComponentF context a
      -> WriterT ({ onUnmount :: Effect Unit, nodesSig :: Signal (Array Node) }) Effect a
    interpreter = case _ of
      ComponentElement { props, children } free -> do
        el <- liftEffect $ hydrateNode realNodeRef Element.fromNode "Element"

        rnr <- liftEffect $ new <=< firstChild $ Element.toNode el
        { onUnmount: onu, nodesSig: nds } <- liftEffect $ hydrateNodesSig rnr ctx children

        unRegisterProps <- liftEffect $ registerPropsWithoutInit el props
        unRegisterChildren <- liftEffect $ registerChildren (Element.toNode el) nds

        let
          onUnmount = do
            unRegisterProps
            unRegisterChildren
            onu

        tell { onUnmount, nodesSig: pure [ Element.toNode el ] }

        pure free
      ComponentText textSig free -> do
        txt <- liftEffect $ hydrateNode realNodeRef Text.fromNode "Text"

        unRegisterText <- liftEffect $ registerText txt textSig

        let
          onUnmount = unRegisterText

        tell { onUnmount, nodesSig: pure [ Text.toNode txt ] }

        pure free
      ComponentRawElement { props, innerHtml } free -> do
        el <- liftEffect $ hydrateNode realNodeRef Element.fromNode "RawElement"

        unRegisterProps <- liftEffect $ registerPropsWithoutInit el props
        unRegisterInnerHtml <- liftEffect $ registerInnerHtml el innerHtml

        let
          onUnmount = do
            unRegisterProps
            unRegisterInnerHtml

        tell { onUnmount, nodesSig: pure [ Element.toNode el ] }

        pure free
      ComponentDocType {} free -> do
        dt <- liftEffect $ hydrateNode realNodeRef DocumentType.fromNode "DocType"

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
