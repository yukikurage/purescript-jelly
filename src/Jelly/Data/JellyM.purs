module Jelly.Data.JellyM
  ( JellyM(..)
  , runAlone
  ) where

import Prelude

import Control.Monad.Reader (class MonadTrans, ReaderT, lift, runReaderT)
import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect)
import Jelly.Data.DependenciesSolver (Observer)

-- resolveDependency addDependencyListener removeDependencyListener

newtype JellyM m a = JellyM (ReaderT (Maybe (Observer m)) m a)

derive newtype instance Functor m => Functor (JellyM m)
derive newtype instance Apply m => Apply (JellyM m)
derive newtype instance Applicative m => Applicative (JellyM m)
derive newtype instance Bind m => Bind (JellyM m)
derive newtype instance Monad m => Monad (JellyM m)
derive newtype instance MonadEffect m => MonadEffect (JellyM m)
instance MonadTrans JellyM where
  lift = JellyM <<< lift

-- | Convert JellyM m a to m a
-- | Dependencies will no longer be tracked
runAlone :: forall m a. JellyM m a -> m a
runAlone (JellyM m) = runReaderT m Nothing
