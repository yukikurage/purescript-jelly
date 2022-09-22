module Jelly.Core.Data.Signal
  ( Atom
  , Signal
  , defer
  , launch
  , launch_
  , modifyAtom
  , modifyAtom_
  , readSignal
  , signal
  , signalWithoutEq
  , writeAtom
  ) where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Safely (for_)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)

foreign import data Atom :: Type -> Type
foreign import data Observer :: Type

newtype Signal a = Signal (ReaderT Observer Effect a)

derive newtype instance Functor Signal
derive newtype instance Apply Signal
derive newtype instance Applicative Signal
derive newtype instance Bind Signal
derive newtype instance Monad Signal
derive newtype instance MonadEffect Signal
derive newtype instance MonadReader Observer Signal
derive newtype instance MonadAsk Observer Signal
derive newtype instance MonadRec Signal
derive newtype instance Semigroup a => Semigroup (Signal a)
derive newtype instance Monoid a => Monoid (Signal a)

foreign import connect :: forall a. Observer -> Atom a -> Effect Unit
foreign import disconnect :: forall a. Observer -> Atom a -> Effect Unit
foreign import newAtom :: forall a. (a -> a -> Boolean) -> a -> Effect (Atom a)
foreign import newObserver :: (Observer -> Effect Unit) -> Effect Observer
foreign import getObservers :: forall a. Atom a -> Effect (Array Observer)
foreign import getAtomValue :: forall a. Atom a -> Effect a
foreign import setAtomValue :: forall a. Atom a -> a -> Effect Unit
foreign import getObserverSignal :: Observer -> Effect (Observer -> Effect Unit)
foreign import getObserverCallbacks :: Observer -> Effect (Array (Effect Unit))
foreign import addObserverCallback :: Observer -> Effect Unit -> Effect Unit
foreign import clearObserverCallbacks :: Observer -> Effect Unit
foreign import getEq :: forall a. Atom a -> a -> a -> Boolean

readSignal :: forall m a. MonadEffect m => Signal a -> m a
readSignal (Signal sig) = liftEffect $ runReaderT sig =<<
  (newObserver $ const $ pure unit)

defer :: Effect Unit -> Signal Unit
defer callback = do
  obs <- ask
  liftEffect $ addObserverCallback obs callback

launch :: forall m. MonadEffect m => Signal Unit -> m (Effect Unit)
launch (Signal sig) = liftEffect $ do
  obs <- newObserver $ runReaderT sig
  runReaderT sig obs
  pure do
    callbacks <- getObserverCallbacks obs
    clearObserverCallbacks obs
    for_ callbacks identity

launch_ :: forall m. MonadEffect m => Signal Unit -> m Unit
launch_ sig = liftEffect $ launch sig $> unit

signal
  :: forall m a
   . MonadEffect m
  => Eq a
  => a
  -> m (Signal a /\ Atom a)
signal init = liftEffect do
  atom <- newAtom eq init

  let
    sig = do
      obs <- ask
      liftEffect $ connect obs atom
      defer $ disconnect obs atom
      liftEffect $ getAtomValue atom

  pure $ sig /\ atom

signalWithoutEq :: forall m a. MonadEffect m => a -> m (Signal a /\ Atom a)
signalWithoutEq init = liftEffect do
  atom <- newAtom (const $ const false) init

  let
    sig = do
      obs <- ask
      liftEffect $ connect obs atom
      defer $ disconnect obs atom
      liftEffect $ getAtomValue atom

  pure $ sig /\ atom

modifyAtom :: forall m a. MonadEffect m => Atom a -> (a -> a) -> m a
modifyAtom atom f = liftEffect $ do
  atomValue <- getAtomValue atom

  let
    newAtomValue = f atomValue

  when (not $ getEq atom atomValue newAtomValue) do
    observers <- getObservers atom
    for_ observers \obs -> do
      callbacks <- getObserverCallbacks obs
      clearObserverCallbacks obs
      for_ callbacks identity

    setAtomValue atom newAtomValue

    for_ observers \obs -> do
      s <- getObserverSignal obs
      s obs

  pure newAtomValue

modifyAtom_
  :: forall m a. MonadEffect m => Atom a -> (a -> a) -> m Unit
modifyAtom_ atom f = void $ modifyAtom atom f

writeAtom :: forall m a. MonadEffect m => Atom a -> a -> m Unit
writeAtom atom v = modifyAtom_ atom $ const v
