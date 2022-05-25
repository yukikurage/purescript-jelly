module Jelly.Data.Hooks where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT(..), runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Effect.Class (class MonadEffect)
import Jelly.Data.Jelly (Jelly)

newtype Hooks r a = Hooks (ReaderT r Jelly a)

derive newtype instance Functor (Hooks r)
derive newtype instance Apply (Hooks r)
derive newtype instance Applicative (Hooks r)
derive newtype instance Bind (Hooks r)
derive newtype instance Monad (Hooks r)
derive newtype instance MonadEffect (Hooks r)
derive newtype instance MonadAsk r (Hooks r)
derive newtype instance MonadRec (Hooks r)

runHooks :: forall r a. r -> Hooks r a -> Jelly a
runHooks r (Hooks h) = runReaderT h r

liftJelly :: forall r a. Jelly a -> Hooks r a
liftJelly = Hooks <<< ReaderT <<< const
