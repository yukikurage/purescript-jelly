module Jelly.Data.Hooks where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.Writer (class MonadTell, class MonadWriter, WriterT, runWriterT)
import Data.Newtype (class Newtype)
import Data.Tuple.Nested (type (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect)

newtype Hooks context a = Hooks (ReaderT context (WriterT (Effect Unit) Effect) a)

derive instance Newtype (Hooks context a) _
derive newtype instance Functor (Hooks context)
derive newtype instance Apply (Hooks context)
derive newtype instance Applicative (Hooks context)
derive newtype instance Bind (Hooks context)
derive newtype instance Monad (Hooks context)
derive newtype instance MonadRec (Hooks context)
derive newtype instance MonadEffect (Hooks context)
derive newtype instance MonadAsk context (Hooks context)
derive newtype instance MonadReader context (Hooks context)
derive newtype instance MonadTell (Effect Unit) (Hooks context)
derive newtype instance MonadWriter (Effect Unit) (Hooks context)

runHooks :: forall context a. Hooks context a -> context -> Effect (a /\ Effect Unit)
runHooks (Hooks m) c = runWriterT $ runReaderT m c
