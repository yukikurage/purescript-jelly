module Jelly.Data.HookM
  ( HookM(..)
  , runHookM
  ) where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Jelly.Data.Emitter (Emitter, emit, newEmitter)

newtype HookM r a = HookM
  ( ReaderT
      ( { unmountEmitter :: Emitter Effect Unit
        , r :: r
        }
      )
      Effect
      a
  )

derive newtype instance Functor (HookM r)
derive newtype instance Apply (HookM r)
derive newtype instance Applicative (HookM r)
derive newtype instance Bind (HookM r)
derive newtype instance Monad (HookM r)
derive newtype instance MonadEffect (HookM r)
derive newtype instance MonadRec (HookM r)
instance MonadAsk r (HookM r) where
  ask = HookM do
    { r } <- ask
    pure r

runHookM
  :: forall r a
   . r
  -> HookM r a
  -> Effect (a /\ Effect Unit)
runHookM r (HookM hook) = do
  unmountEmitter <- newEmitter
  a <- runReaderT hook { unmountEmitter, r }
  pure $ a /\ emit unmountEmitter unit
