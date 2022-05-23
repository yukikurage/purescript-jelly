module Jelly.Data.HookM
  ( HookM(..)
  , runHookM
  ) where

import Prelude

import Control.Monad.Reader (ReaderT, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Jelly.Data.Emitter (Emitter, emit, newEmitter)
import Jelly.Data.Machine (Machine)

newtype HookM (m :: Type -> Type) a = HookM
  ( ReaderT
      ( { unmountEmitter :: Emitter Effect Unit
        , machine :: Machine m
        }
      )
      Effect
      a
  )

derive newtype instance Functor (HookM m)
derive newtype instance Apply (HookM m)
derive newtype instance Applicative (HookM m)
derive newtype instance Bind (HookM m)
derive newtype instance Monad (HookM m)
derive newtype instance MonadEffect (HookM m)
derive newtype instance MonadRec (HookM m)

runHookM
  :: forall m a
   . Machine m
  -> HookM m a
  -> Effect (a /\ Effect Unit)
runHookM machine (HookM hook) = do
  unmountEmitter <- newEmitter
  a <- runReaderT hook { unmountEmitter, machine }
  pure $ a /\ emit unmountEmitter unit
