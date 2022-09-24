module Jelly.Core.Data.Hooks where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.Writer (class MonadTell, class MonadWriter, WriterT, runWriterT)
import Data.Newtype (class Newtype)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Jelly.Core.Data.Component (Component, lifeCycleC)

newtype Hooks context a = Hooks (ReaderT (Record context) (WriterT (Effect Unit) Effect) a)

derive instance Newtype (Hooks context a) _
derive newtype instance Functor (Hooks context)
derive newtype instance Apply (Hooks context)
derive newtype instance Applicative (Hooks context)
derive newtype instance Bind (Hooks context)
derive newtype instance Monad (Hooks context)
derive newtype instance MonadRec (Hooks context)
derive newtype instance MonadEffect (Hooks context)
derive newtype instance MonadAsk (Record context) (Hooks context)
derive newtype instance MonadReader (Record context) (Hooks context)
derive newtype instance MonadTell (Effect Unit) (Hooks context)
derive newtype instance MonadWriter (Effect Unit) (Hooks context)

hooks :: forall context. Hooks context (Component context) -> Component context
hooks (Hooks m) = lifeCycleC \c -> do
  component /\ onUnmount <- runWriterT $ runReaderT m c
  pure { component, onUnmount }
