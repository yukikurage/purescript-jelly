module Jelly.Render (render) where

import Prelude

import Control.Monad.Writer (WriterT, runWriterT, tell)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Jelly.Component (Component, ComponentF(..), runComponentM)
import Jelly.Prop (renderProps)
import Signal (readSignal)
import Signal.Hooks (Hooks, liftHooks)

type RenderM context a = WriterT String (Hooks context) a

renderInterpreter :: forall context. ComponentF context ~> RenderM context
renderInterpreter = case _ of
  ComponentElement { tag, props, children } free -> do
    propsRendered <- liftEffect $ renderProps props
    childrenRendered <- liftHooks $ render children
    tell $ "<" <> tag <> propsRendered <> ">" <> childrenRendered <> "</" <> tag <> ">"
    pure free
  ComponentElementNS { namespace, tag, props, children } free -> do
    propsRendered <- liftEffect $ renderProps props
    childrenRendered <- liftHooks $ render children
    tell $ "<" <> tag <> " xmlns=\"" <> namespace <> "\"" <> propsRendered <> ">"
      <> childrenRendered
      <> "</"
      <> tag
      <> ">"
    pure free
  ComponentVoidElement { tag, props } free -> do
    propsRendered <- liftEffect $ renderProps props
    tell $ "<" <> tag <> propsRendered <> ">"
    pure free
  ComponentText textSig free -> do
    tell =<< readSignal textSig
    pure free
  ComponentRaw innerHtmlSig free -> do
    tell =<< readSignal innerHtmlSig
    pure free
  ComponentDocType { name, publicId, systemId } free -> do
    tell $ "<!DOCTYPE " <> name <> " " <> publicId <> " " <> systemId <> ">"
    pure free
  ComponentSignal cmpSig free -> do
    component <- readSignal cmpSig
    tell =<< liftHooks (render component)
    pure free

render :: forall context. Component context -> Hooks context String
render cmp = do
  _ /\ rendered <- runWriterT $ runComponentM renderInterpreter cmp
  pure rendered
