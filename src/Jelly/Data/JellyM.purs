module Jelly.Data.JellyM
  ( JellyM(..)
  , alone
  ) where

import Prelude

import Control.Monad.Reader (ReaderT, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Jelly.Data.DependenciesSolver (Observer)

newtype JellyM a = JellyM
  (ReaderT (Maybe Observer) Effect a)

derive newtype instance Functor JellyM
derive newtype instance Apply JellyM
derive newtype instance Applicative JellyM
derive newtype instance Bind JellyM
derive newtype instance Monad JellyM
derive newtype instance MonadEffect JellyM
derive newtype instance MonadRec JellyM

alone :: forall a. JellyM a -> Effect a
alone (JellyM f) = runReaderT f Nothing
