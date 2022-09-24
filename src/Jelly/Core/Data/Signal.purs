module Jelly.Core.Data.Signal where

import Prelude

import Control.Apply (lift2)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (new, read, write)

foreign import data Atom :: Type -> Type

type Listener a = a -> Effect (Effect Unit)

foreign import newAtom :: forall a. a -> Effect (Atom a)
foreign import listenAtom :: forall a. Atom a -> Listener a -> Effect (Effect Unit)
foreign import writeAtomImpl :: forall a. Atom a -> a -> Effect Unit
foreign import readAtom :: forall a. Atom a -> Effect a

newtype Signal a = Signal
  { listen :: Listener a -> Effect (Effect Unit)
  , get :: Effect a
  }

instance Functor Signal where
  map f sig = Signal
    { listen: \callback -> listen sig \a -> callback $ f a
    , get: f <$> get sig
    }

instance Apply Signal where
  apply signalF signalA = Signal
    { listen: \callback -> do
        listen signalF \f -> listen signalA \a -> callback $ f a
    , get: get signalF <*> get signalA
    }

instance Applicative Signal where
  pure a = Signal
    { listen: \callback -> callback a
    , get: pure a
    }

instance Bind Signal where
  bind signalA f = Signal
    { listen: \callback -> do
        unListenA <- listen signalA \a -> do
          unListenB <- listen (f a) callback
          pure $ unListenB
        pure unListenA
    , get: do
        a <- get signalA
        get $ f a
    }

instance Semigroup a => Semigroup (Signal a) where
  append = lift2 append

instance Monoid a => Monoid (Signal a) where
  mempty = pure mempty

get :: forall m a. MonadEffect m => Signal a -> m a
get (Signal { get: g }) = liftEffect g

listen :: forall m a. MonadEffect m => Signal a -> Listener a -> m (Effect Unit)
listen (Signal { listen: l }) callback = liftEffect $ l callback

signal :: forall m a. MonadEffect m => a -> m (Signal a /\ Atom a)
signal init = liftEffect do
  atom <- newAtom init
  pure $
    Signal
      { listen: \callback -> listenAtom atom callback
      , get: readAtom atom
      } /\ atom

writeAtom :: forall m a. MonadEffect m => Atom a -> a -> m Unit
writeAtom atom a = liftEffect $ writeAtomImpl atom a

modifyAtom :: forall m a. MonadEffect m => Atom a -> (a -> a) -> m a
modifyAtom atom f = liftEffect do
  a <- readAtom atom
  writeAtomImpl atom $ f a
  pure a

modifyAtom_
  :: forall m a. MonadEffect m => Atom a -> (a -> a) -> m Unit
modifyAtom_ atom f = void $ modifyAtom atom f

perform :: forall m a. MonadEffect m => Signal a -> Listener a -> m Unit
perform sgn lsn = liftEffect do
  unListenRef <- new $ pure unit
  flip write unListenRef =<< listen sgn \a -> do
    callback <- lsn a
    pure $ callback *> join (read unListenRef)
  pure unit
