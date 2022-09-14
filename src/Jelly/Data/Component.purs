module Jelly.Data.Component where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, runReaderT)
import Control.Monad.Writer (class MonadTell, class MonadWriter, WriterT, runWriterT)
import Data.Tuple (snd)
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Jelly.Data.Emitter (Emitter)
import Jelly.Data.Instance (Instance)
import Jelly.Data.Signal (Signal)

type ComponentInternal context = { unmountEmitter :: Emitter, context :: context }

newtype ComponentM context a = Component
  (ReaderT (ComponentInternal context) (WriterT (Signal (Array Instance)) Effect) a)

derive newtype instance Functor (ComponentM context)
derive newtype instance Apply (ComponentM context)
derive newtype instance Applicative (ComponentM context)
derive newtype instance Bind (ComponentM context)
derive newtype instance Monad (ComponentM context)
derive newtype instance MonadAsk (ComponentInternal context) (ComponentM context)
derive newtype instance MonadReader (ComponentInternal context) (ComponentM context)
derive newtype instance MonadTell (Signal (Array Instance)) (ComponentM context)
derive newtype instance MonadWriter (Signal (Array Instance)) (ComponentM context)
derive newtype instance MonadEffect (ComponentM context)
derive newtype instance Semigroup a => Semigroup (ComponentM context a)
derive newtype instance Monoid a => Monoid (ComponentM context a)

type Component context = ComponentM context Unit

runComponent
  :: forall context
   . Component context
  -> ComponentInternal context
  -> Effect (Signal (Array Instance))
runComponent (Component m) internal = do
  snd <$> runWriterT (runReaderT m internal)
