module Jelly.Render where

import Prelude

import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.Writer (class MonadTell, class MonadWriter, WriterT, lift, runWriterT, tell)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Component (class Component)
import Jelly.Hooks (class MonadHooks)
import Jelly.Prop (renderProps)
import Jelly.Signal (readSignal)

newtype RenderM a = RenderM (WriterT String Effect a)

derive newtype instance Functor RenderM
derive newtype instance Apply RenderM
derive newtype instance Applicative RenderM
derive newtype instance Bind RenderM
derive newtype instance Monad RenderM
derive newtype instance MonadEffect RenderM
derive newtype instance MonadRec RenderM
derive newtype instance MonadTell String RenderM
derive newtype instance MonadWriter String RenderM
instance MonadHooks RenderM where
  useCleaner = RenderM <<< lift <<< identity
  useHooks sig = RenderM $ do
    RenderM wtr <- liftEffect $ readSignal sig
    a /\ rendered <- liftEffect $ runWriterT wtr
    tell rendered
    pure $ pure a

instance Component RenderM where
  el tag props children = do
    propsRendered <- liftEffect $ renderProps props
    childrenRendered <- liftEffect $ render children
    tell $ "<" <> tag <> propsRendered <> ">" <> childrenRendered <> "</" <> tag <> ">"
  elNS namespace tag props children = do
    propsRendered <- liftEffect $ renderProps props
    childrenRendered <- liftEffect $ render children
    tell $ "<" <> tag <> " xmlns=\"" <> namespace <> "\"" <> propsRendered <> ">" <> childrenRendered <> "</" <> tag <> ">"
  elVoid tag props = do
    propsRendered <- liftEffect $ renderProps props
    tell $ "<" <> tag <> propsRendered <> ">"
  rawSig innerHtmlSig = do
    tell =<< readSignal innerHtmlSig
  textSig ts = do
    tell =<< readSignal ts
  doctype name publicId systemId = do
    tell $ "<!DOCTYPE " <> name <> " " <> publicId <> " " <> systemId <> ">"

render :: RenderM Unit -> Effect String
render (RenderM m) = do
  _ /\ rendered <- runWriterT m
  pure rendered
