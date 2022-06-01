module Jelly.Data.Hooks where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT(..), runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Data.Maybe (Maybe)
import Effect.Class (class MonadEffect)
import Jelly.Data.Jelly (Jelly)
import Jelly.Data.Jelly.Class (class MonadJelly)
import Web.DOM (Node)

type HooksInternal r =
  { contexts :: r, parentNode :: Node, anchorNode :: Maybe Node }

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
