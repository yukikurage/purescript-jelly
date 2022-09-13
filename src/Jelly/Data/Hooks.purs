module Jelly.Data.Hooks where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.Component (Component, ComponentInternal)

newtype Hooks context a = Hooks (ReaderT (ComponentInternal context) Effect a)

derive newtype instance Functor (Hooks r)
derive newtype instance Apply (Hooks r)
derive newtype instance Applicative (Hooks r)
derive newtype instance Bind (Hooks r)
derive newtype instance Monad (Hooks r)
derive newtype instance MonadAsk (ComponentInternal context) (Hooks context)
derive newtype instance MonadReader (ComponentInternal context) (Hooks context)
derive newtype instance MonadEffect (Hooks r)
derive newtype instance MonadRec (Hooks r)

makeComponent :: forall context. Hooks context (Component context) -> Component context
makeComponent (Hooks reader) = do
  internal <- ask
  component <- liftEffect $ runReaderT reader internal
  component
