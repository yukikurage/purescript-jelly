module Jelly.Core.Mount where

import Prelude

import Control.Monad.Writer (WriterT, runWriterT, tell)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (Ref, new, read, write)
import Jelly.Core.Data.Component (Component, ComponentF(..), foldComponent)
import Jelly.Core.Data.Prop (registerProps, registerPropsUpdate)
import Jelly.Core.Data.Signal (Signal, listen, signal, writeAtom)
import Web.DOM (Document, DocumentType, Element, Node, Text)
import Web.DOM.Document (createElement, createTextNode)
import Web.DOM.DocumentType as DocumentType
import Web.DOM.Element as Element
import Web.DOM.Node (firstChild, nextSibling, setTextContent)
import Web.DOM.Text as Text
import Web.HTML (window)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.Window (document)

foreign import updateChildren :: Node -> Array Node -> Effect Unit
foreign import createDocumentType
  :: String -> String -> String -> Document -> Effect DocumentType

foreign import setInnerHtml :: Element -> String -> Effect Unit

registerChildren :: Node -> Signal (Array Node) -> Effect (Effect Unit)
registerChildren elem chlSig = listen chlSig \chl -> do
  updateChildren elem chl
  mempty

registerText :: Text -> Signal String -> Effect (Effect Unit)
registerText txt txtSig = listen txtSig \tx -> do
  setTextContent tx $ Text.toNode txt
  mempty

registerInnerHtml :: Element -> Signal String -> Effect (Effect Unit)
registerInnerHtml elem htmlSig = listen htmlSig \html -> do
  setInnerHtml elem html
  mempty

-- | Component を node の 列の Signal に変換
-- | realNodeRef : Hydration するときに使う
makeNodesSig
  :: forall context
   . Ref (Maybe Node)
  -> Record context
  -> Component context
  -> Effect { onUnmount :: Effect Unit, nodesSig :: Signal (Array Node) }
makeNodesSig realNodeRef ctx cmp = do
  w <- window
  d <- HTMLDocument.toDocument <$> document w

  let
    interpreter
      :: forall a
       . ComponentF context a
      -> WriterT ({ onUnmount :: Effect Unit, nodesSig :: Signal (Array Node) }) Effect a
    interpreter = case _ of
      ComponentElement { tag, props, children } free -> do
        realNodeMaybe <- liftEffect $ read realNodeRef
        let
          realElMaybe = Element.fromNode =<< realNodeMaybe

        el /\ unRegisterProps <- liftEffect $ case realElMaybe of
          Just realEl -> do
            nxs <- nextSibling $ Element.toNode realEl

            unRegisterProps <- liftEffect $ registerPropsUpdate realEl props

            write nxs realNodeRef
            pure $ realEl /\ unRegisterProps
          Nothing -> do
            el <- createElement tag d

            unRegisterProps <- liftEffect $ registerProps el props

            pure $ el /\ unRegisterProps

        rnr <- liftEffect $ new <=< firstChild $ Element.toNode el
        { onUnmount: onu, nodesSig: nds } <- liftEffect $ makeNodesSig rnr ctx children

        unRegisterChildren <- liftEffect $ registerChildren (Element.toNode el) nds

        let
          onUnmount = do
            unRegisterProps
            unRegisterChildren
            onu

        tell { onUnmount, nodesSig: pure [ Element.toNode el ] }

        pure free
      ComponentText textSig free -> do
        realNodeMaybe <- liftEffect $ read realNodeRef
        let
          realTxtMaybe = Text.fromNode =<< realNodeMaybe

        txt <- liftEffect case realTxtMaybe of
          Just txt -> do
            nxs <- liftEffect $ nextSibling $ Text.toNode txt
            liftEffect $ write nxs realNodeRef
            pure txt
          Nothing -> liftEffect $ createTextNode "" d

        unRegisterText <- liftEffect $ registerText txt textSig

        let
          onUnmount = unRegisterText

        tell { onUnmount, nodesSig: pure [ Text.toNode txt ] }

        pure free
      ComponentRawElement { tag, props, innerHtml } free -> do
        realNodeMaybe <- liftEffect $ read realNodeRef
        let
          realElMaybe = Element.fromNode =<< realNodeMaybe

        el <- liftEffect $ case realElMaybe of
          Just realEl -> do
            nxs <- nextSibling $ Element.toNode realEl
            write nxs realNodeRef
            pure realEl
          Nothing -> createElement tag d

        unRegisterProps <- liftEffect $ registerProps el props
        unRegisterInnerHtml <- liftEffect $ registerInnerHtml el innerHtml

        let
          onUnmount = do
            unRegisterProps
            unRegisterInnerHtml

        tell { onUnmount, nodesSig: pure [ Element.toNode el ] }

        pure free
      ComponentDocType { name, publicId, systemId } free -> do
        realNodeMaybe <- liftEffect $ read realNodeRef
        let
          realDocTypeMaybe = DocumentType.fromNode =<< realNodeMaybe

        docType <- liftEffect case realDocTypeMaybe of
          Just docType -> do
            nxs <- liftEffect $ nextSibling $ DocumentType.toNode docType
            liftEffect $ write nxs realNodeRef
            pure docType
          Nothing -> liftEffect $ createDocumentType name publicId systemId d

        let
          onUnmount = mempty

        tell { onUnmount, nodesSig: pure [ DocumentType.toNode docType ] }

        pure free
      ComponentSignal cmpSig free -> do
        nodesSig /\ nodesAtom <- signal $ pure []

        unListen <- listen cmpSig \c -> do
          { onUnmount: onu, nodesSig: nds } <- makeNodesSig realNodeRef ctx c
          writeAtom nodesAtom nds
          pure $ onu

        tell { onUnmount: unListen, nodesSig: join nodesSig }

        pure free
      ComponentLifeCycle eff free -> do
        { component: cmpL, onUnmount: onuL } <- liftEffect $ eff ctx

        { onUnmount: onu, nodesSig: nds } <- liftEffect $ makeNodesSig realNodeRef ctx cmpL

        tell { onUnmount: onuL *> onu, nodesSig: nds }

        pure free
  _ /\ { onUnmount, nodesSig } <- runWriterT $ foldComponent interpreter cmp

  pure { onUnmount, nodesSig }

mount
  :: forall context. Record context -> Component context -> Node -> Effect (Effect Unit)
mount ctx cmp node = do
  realNodeRef <- new Nothing
  { onUnmount, nodesSig } <- makeNodesSig realNodeRef ctx cmp

  unRegisterChildren <- registerChildren node nodesSig
  pure $ onUnmount *> unRegisterChildren

hydrate
  :: forall context. Record context -> Component context -> Node -> Effect (Effect Unit)
hydrate ctx cmp node = do
  realNodeRef <- new =<< firstChild node
  { onUnmount, nodesSig } <- makeNodesSig realNodeRef ctx cmp
  unRegisterChildren <- registerChildren node nodesSig
  pure $ onUnmount *> unRegisterChildren
