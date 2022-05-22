module Jelly.Data.HookM
  ( HookM(..)
  , runHookM
  ) where

import Prelude

import Control.Monad.Reader (class MonadTrans, ReaderT, lift, runReaderT)
import Data.Foldable (sequence_)
import Data.Tuple.Nested (type (/\), (/\))
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.Emitter (Emitter, emit, newEmitter)

newtype HookM (m :: Type -> Type) a = HookM
  ( ReaderT
      ( { unmountEmitter :: Emitter m Unit
        }
      )
      m
      a
  )

derive newtype instance Functor m => Functor (HookM m)
derive newtype instance Apply m => Apply (HookM m)
derive newtype instance Applicative m => Applicative (HookM m)
derive newtype instance Bind m => Bind (HookM m)
derive newtype instance Monad m => Monad (HookM m)
derive newtype instance MonadEffect m => MonadEffect (HookM m)
instance MonadTrans HookM where
  lift = HookM <<< lift

runHookM :: forall m a. MonadEffect m => HookM m a -> m (a /\ (m Unit))
runHookM (HookM hook) = do
  unmountEmitter <- liftEffect newEmitter
  a <- runReaderT hook { unmountEmitter }
  pure $ a /\ (sequence_ $ emit unmountEmitter unit)
