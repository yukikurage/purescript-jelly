module Jelly.Data.Signal where

import Prelude

import Control.Monad.Cont (ContT(..), runContT)
import Control.Safely (for_)
import Data.List (List, (:))
import Effect (Effect)
import Effect.Class (class MonadEffect)

newtype Signal a = Signal (ContT (List (Effect Unit)) Effect a)

derive newtype instance Functor Signal
derive newtype instance Apply Signal
derive newtype instance Applicative Signal
derive newtype instance Bind Signal
derive newtype instance Monad Signal
derive newtype instance MonadEffect Signal

data SignalId a = SignalId ((a -> a) -> Effect Unit)

runSignal :: forall a. Signal a -> Effect (Effect Unit)
runSignal (Signal cont) = do
  ds <- runContT cont $ const $ pure $ mempty
  pure $ for_ ds identity

defer :: Effect Unit -> Signal Unit
defer d = Signal $ ContT $ \cont -> do
  ds <- cont unit
  pure $ d : ds

newSignal :: forall a. a -> Signal a /\ SignalId a
newSignal
