module Jelly.Data.Hooks where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT(..), runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Effect.Class (class MonadEffect)
import Jelly.Data.Jelly (Jelly)
import Jelly.Data.Jelly.Class (class MonadJelly)
import Jelly.Data.Place (Place)

type HooksInternal r =
  { contexts :: r, parentPlace :: Place }

newtype Hooks r a = Hooks (ReaderT (HooksInternal r) Jelly a)

derive newtype instance Functor (Hooks r)
derive newtype instance Apply (Hooks r)
derive newtype instance Applicative (Hooks r)
derive newtype instance Bind (Hooks r)
derive newtype instance Monad (Hooks r)
derive newtype instance MonadEffect (Hooks r)
derive newtype instance MonadAsk (HooksInternal r) (Hooks r)
derive newtype instance MonadRec (Hooks r)

runHooks :: forall r a. HooksInternal r -> Hooks r a -> Jelly a
runHooks r (Hooks h) = runReaderT h r

instance MonadJelly (Hooks r) where
  liftJelly = Hooks <<< ReaderT <<< const
