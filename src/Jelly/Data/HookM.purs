module Jelly.Data.HookM
  ( HookM(..)
  , runHookM
  ) where

import Prelude

import Control.Monad.Reader (class MonadTrans, ReaderT, lift, runReaderT)
import Effect.Class (class MonadEffect)
import Jelly.Data.Emitter (Emitter)

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

runHookM :: forall m a. Monad m => HookM m a -> Emitter m Unit -> m a
runHookM (HookM hook) unmountEmitter = runReaderT hook { unmountEmitter }
