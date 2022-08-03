module Jelly.Data.Signal where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Control.Safely (for_)
import Data.Tuple (Tuple(..))
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

foreign import connect :: forall a. Observer -> Atom a -> Effect Unit
foreign import disconnect :: forall a. Observer -> Atom a -> Effect Unit
foreign import newAtom :: forall a. a -> Effect (Atom a)
foreign import newObserver :: (Observer -> Effect Unit) -> Effect Observer
foreign import getObservers :: forall a. Atom a -> Effect (Array Observer)
foreign import getAtomValue :: forall a. Atom a -> Effect a
foreign import setAtomValue :: forall a. Atom a -> a -> Effect Unit
foreign import getObserverSignal :: Observer -> Effect (Observer -> Effect Unit)
foreign import getObserverCallbacks :: Observer -> Effect (Array (Effect Unit))
foreign import addObserverCallback :: Observer -> Effect Unit -> Effect Unit
foreign import clearObserverCallbacks :: Observer -> Effect Unit

detach :: forall a. Signal a -> Effect a
detach (Signal sig) = runReaderT sig =<<
  (newObserver $ const $ pure unit)

defer :: Effect Unit -> Signal Unit
defer callback = do
  obs <- ask
  liftEffect $ addObserverCallback obs callback

launch :: Signal Unit -> Effect (Effect Unit)
launch (Signal sig) = do
  obs <- newObserver $ runReaderT sig
  runReaderT sig obs
  pure do
    callbacks <- getObserverCallbacks obs
    for_ callbacks identity
    clearObserverCallbacks obs

launch_ :: Signal Unit -> Effect Unit
launch_ sig = launch sig $> unit

signal
  :: forall m a
   . MonadEffect m
  => a
  -> m (Tuple (Signal a) ((a -> a) -> Effect Unit))
signal init = liftEffect do
  atom <- newAtom init

  let
    sig = do
      obs <- ask
      liftEffect $ connect obs atom
      defer $ disconnect obs atom
      liftEffect $ getAtomValue atom

    mod f = do
      observers <- getObservers atom
      for_ observers \obs -> do
        callbacks <- getObserverCallbacks obs
        for_ callbacks identity
        clearObserverCallbacks obs

      setAtomValue atom <<< f =<< getAtomValue atom

      for_ observers \obs -> do
        s <- getObserverSignal obs
        s obs

  pure $ Tuple sig mod
