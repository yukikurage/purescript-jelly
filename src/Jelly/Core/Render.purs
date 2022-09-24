module Jelly.Core.Render where

import Prelude

import Control.Monad.Writer (WriterT, runWriterT, tell)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Core.Data.Component (Component, ComponentF(..), foldComponent)
import Jelly.Core.Data.Prop (renderProps)
import Jelly.Core.Data.Signal (get)

render :: forall context. Record context -> Component context -> Effect String
render ctx cmp = do
  let
    interpreter :: forall a. ComponentF context a -> WriterT String Effect a
    interpreter = case _ of
      ComponentElement { tag, props, children } free -> do
        propsRendered <- liftEffect $ renderProps props
        childrenRendered <- liftEffect $ render ctx children
        tell $ "<" <> tag <> propsRendered <> ">" <> childrenRendered <> "</" <> tag <> ">"
        pure free
      ComponentText textSig free -> do
        tell =<< get textSig
        pure free
      ComponentSignal cmpSig free -> do
        component <- get cmpSig
        tell =<< liftEffect (render ctx component)
        pure free
      ComponentLifeCycle eff free -> do
        { component } <- liftEffect $ eff ctx
        tell =<< liftEffect (render ctx component)
        pure free
  _ /\ w <- runWriterT $ foldComponent interpreter cmp

  pure w
