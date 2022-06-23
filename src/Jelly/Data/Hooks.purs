module Jelly.Data.Hooks where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT, lift, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Effect.Class (class MonadEffect)
import Jelly.Data.Jelly (class MonadJelly, Jelly)

newtype Hooks r a = Hooks (ReaderT r Jelly a)

derive newtype instance Functor (Hooks r)
derive newtype instance Apply (Hooks r)
derive newtype instance Applicative (Hooks r)
derive newtype instance Bind (Hooks r)
derive newtype instance Monad (Hooks r)
derive newtype instance MonadEffect (Hooks r)
derive newtype instance MonadAsk r (Hooks r)
derive newtype instance MonadRec (Hooks r)
instance MonadJelly (Hooks r) where
  liftJelly = Hooks <<< lift

runHooks
  :: forall r a
   . r
  -> Hooks r a
  -> Jelly a
runHooks context (Hooks h) = runReaderT h context
