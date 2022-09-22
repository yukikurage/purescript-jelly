module Jelly.Core.Data.Hooks where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.Writer (class MonadTell, class MonadWriter, WriterT, runWriterT)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Core.Data.Component (Component, ComponentInternalR, tellUnmountEffect)

type HooksInternalR context = ComponentInternalR context
type HooksInternalW =
  { unmountEffect :: Effect Unit
  }

newtype Hooks context a = Hooks
  (ReaderT (HooksInternalR context) (WriterT HooksInternalW Effect) a)

derive newtype instance Functor (Hooks context)
derive newtype instance Apply (Hooks context)
derive newtype instance Applicative (Hooks context)
derive newtype instance Bind (Hooks context)
derive newtype instance Monad (Hooks context)
derive newtype instance MonadAsk (HooksInternalR context) (Hooks context)
derive newtype instance MonadReader (HooksInternalR context) (Hooks context)
derive newtype instance MonadTell HooksInternalW (Hooks context)
derive newtype instance MonadWriter HooksInternalW (Hooks context)
derive newtype instance MonadEffect (Hooks context)
derive newtype instance Semigroup a => Semigroup (Hooks context a)
derive newtype instance Monoid a => Monoid (Hooks context a)
derive newtype instance MonadRec (Hooks context)

hooks :: forall context. Hooks context (Component context) -> Component context
hooks (Hooks reader) = do
  internal <- ask
  component /\ { unmountEffect } <- liftEffect $ runWriterT $ runReaderT reader internal
  tellUnmountEffect unmountEffect
  component
