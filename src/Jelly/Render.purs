module Jelly.Render
  ( RenderM(..)
  , render
  ) where

import Prelude

import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.Writer (class MonadTell, class MonadTrans, class MonadWriter, WriterT, lift, runWriterT, tell)
import Data.Tuple.Nested (type (/\), (/\))
import Effect.Class (class MonadEffect)
import Jelly.Component (Component, ComponentF(..), foldComponentM)
import Jelly.Hooks (class MonadHooks, useHooks_)
import Jelly.Prop (renderProps)
import Jelly.Signal (Signal)

-- | A monad for rendering a component.
-- | `Signal String` is result.
newtype RenderM m a = RenderM (WriterT (Signal String) m a)

runRenderM :: forall m a. RenderM m a -> m (a /\ Signal String)
runRenderM (RenderM m) = runWriterT m

derive newtype instance Functor m => Functor (RenderM m)
derive newtype instance Monad m => Apply (RenderM m)
derive newtype instance Monad m => Applicative (RenderM m)
derive newtype instance Monad m => Bind (RenderM m)
derive newtype instance Monad m => Monad (RenderM m)
derive newtype instance MonadEffect m => MonadEffect (RenderM m)
derive newtype instance MonadRec m => MonadRec (RenderM m)
derive newtype instance Monad m => MonadTell (Signal String) (RenderM m)
derive newtype instance Monad m => MonadWriter (Signal String) (RenderM m)
derive newtype instance MonadTrans RenderM
derive newtype instance MonadHooks m => MonadHooks (RenderM m)

renderInterpreter
  :: forall m
   . MonadHooks m
  => MonadRec m
  => ComponentF m ~> RenderM m
renderInterpreter = case _ of
  ComponentEl tag props children f -> do
    let propsRendered = renderProps props
    childrenRendered <- lift $ render children
    tell $
      pure ("<" <> tag) <> propsRendered <> pure ">" <> childrenRendered <> pure ("</" <> tag <> ">")
    pure f
  ComponentElNS namespace tag props children f -> do
    let propsRendered = renderProps props
    childrenRendered <- lift $ render children
    tell $ pure ("<" <> tag <> " xmlns=\"" <> namespace <> "\"")
      <> propsRendered
      <> pure ">"
      <> childrenRendered
      <> pure ("</" <> tag <> ">")
    pure f
  ComponentElVoid tag props f -> do
    let propsRendered = renderProps props
    tell $ pure ("<" <> tag) <> propsRendered <> pure ">"
    pure f
  ComponentRawSig innerHtmlSig f -> do
    tell innerHtmlSig
    pure f
  ComponentTextSig ts f -> do
    tell ts
    pure f
  ComponentDoctype name publicId systemId f -> do
    tell $ pure ("<!DOCTYPE " <> name <> " " <> publicId <> " " <> systemId <> ">")
    pure f
  ComponentLifecycle (mSig :: Signal (m (Component m))) f -> do
    let
      mkHook :: m (Component m) -> RenderM m Unit
      mkHook mCmp = do
        cmp <- lift mCmp
        foldComponentM renderInterpreter cmp
    useHooks_ $ mkHook <$> mSig
    pure f

render :: forall m. MonadRec m => MonadHooks m => Component m -> m (Signal String)
render comp = do
  _ /\ rendered <- runRenderM $ foldComponentM renderInterpreter comp
  pure rendered
