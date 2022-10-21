module Jelly.Render where

import Prelude

import Control.Monad.Writer (WriterT, runWriterT, tell)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Component (Component, ComponentF(..), foldComponent)
import Jelly.Data.Hooks (runHooks)
import Jelly.Data.Prop (renderProps)
import Jelly.Data.Signal (readSignal)

render :: forall context. context -> Component context -> Effect String
render ctx cmp = do
  let
    interpreter :: forall a. ComponentF context a -> WriterT String Effect a
    interpreter = case _ of
      ComponentElement { tag, props, children } free -> do
        propsRendered <- liftEffect $ renderProps props
        childrenRendered <- liftEffect $ render ctx children
        tell $ "<" <> tag <> propsRendered <> ">" <> childrenRendered <> "</" <> tag <> ">"
        pure free
      ComponentElementNS { namespace, tag, props, children } free -> do
        propsRendered <- liftEffect $ renderProps props
        childrenRendered <- liftEffect $ render ctx children
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
      ComponentRawElement { tag, props, innerHtml } free -> do
        propsRendered <- liftEffect $ renderProps props
        innerHtmlRendered <- readSignal innerHtml
        tell $ "<" <> tag <> propsRendered <> ">" <> innerHtmlRendered <> "</" <> tag <> ">"
        pure free
      ComponentDocType { name, publicId, systemId } free -> do
        tell $ "<!DOCTYPE " <> name <> " " <> publicId <> " " <> systemId <> ">"
        pure free
      ComponentSignal cmpSig free -> do
        component <- readSignal cmpSig
        tell =<< liftEffect (render ctx component)
        pure free
      ComponentLifeCycle hooks free -> do
        component /\ _ <- liftEffect $ runHooks hooks ctx
        tell =<< liftEffect (render ctx component)
        pure free
  _ /\ w <- runWriterT $ foldComponent interpreter cmp

  pure w
