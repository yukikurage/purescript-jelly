module Jelly.Core.Data.Signal where

import Prelude

import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)

foreign import data Atom :: Type -> Type

foreign import newAtom :: forall a. a -> Effect (Atom a)
foreign import listenAtom :: forall a. Atom a -> (a -> Effect (Effect Unit)) -> Effect (Effect Unit)
foreign import writeAtom :: forall a. Atom a -> a -> Effect Unit
foreign import readAtom :: forall a. Atom a -> Effect a

newtype Signal a = Signal
  { listen :: (a -> Effect (Effect Unit)) -> Effect (Effect Unit)
  , read :: Effect a
  }

instance Functor Signal where
  map f signal = Signal
    { listen: \callback -> listen signal \a -> callback $ f a
    , read: f <$> read signal
    }

instance Apply Signal where
  apply signalF signalA = Signal
    { listen: \callback -> do
        unListenF <- listen signalF \f -> do
          a <- read signalA
          callback $ f a
        unListenA <- listen signalA \a -> do
          f <- read signalF
          callback $ f a
        pure $ unListenF *> unListenA
    , read: read signalF <*> read signalA
    }

instance Applicative Signal where
  pure a = Signal
    { listen: const $ pure $ pure unit
    , read: pure a
    }

read :: forall m a. MonadEffect m => Signal a -> m a
read (Signal { read: r }) = liftEffect r

listen :: forall m a. MonadEffect m => Signal a -> (a -> Effect (Effect Unit)) -> m (Effect Unit)
listen (Signal { listen: l }) callback = liftEffect $ l callback

new :: forall m a. MonadEffect m => a -> m (Signal a /\ Atom a)
new init = liftEffect do
  atom <- newAtom init
  pure $
    Signal
      { listen: \callback -> listenAtom atom callback
      , read: readAtom atom
      } /\ atom

modifyAtom :: forall m a. MonadEffect m => Atom a -> (a -> a) -> m a
modifyAtom atom f = liftEffect do
  a <- readAtom atom
  writeAtom atom $ f a
  pure a

modifyAtom_
  :: forall m a. MonadEffect m => Atom a -> (a -> a) -> m Unit
modifyAtom_ atom f = void $ modifyAtom atom f
