module Jelly.Data.HookM
  ( HookM(..)
  , runHookM
  ) where

import Prelude

import Control.Monad.Reader (class MonadTrans, ReaderT, lift, runReaderT)
import Data.Tuple.Nested (type (/\), (/\))
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.Emitter (Emitter, emit, newEmitter)
import Jelly.Data.Machine (Machine)

newtype HookM (m :: Type -> Type) a = HookM
  ( ReaderT
      ( { unmountEmitter :: Emitter m Unit
        , machine :: Machine m
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

runHookM
  :: forall m a. MonadEffect m => Machine m -> HookM m a -> m (a /\ (m Unit))
runHookM machine (HookM hook) = do
  unmountEmitter <- liftEffect newEmitter
  a <- runReaderT hook { unmountEmitter, machine }
  pure $ a /\ emit unmountEmitter unit
