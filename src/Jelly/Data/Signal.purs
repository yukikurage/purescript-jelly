module Jelly.Data.Signal where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Control.Safely (for_)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Unsafe.Coerce (unsafeCoerce)

foreign import data Atom :: Type -> Type
foreign import data GenericAtom :: Type
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

foreign import connect :: Observer -> GenericAtom -> Effect Unit
foreign import disconnect :: Observer -> GenericAtom -> Effect Unit
foreign import newAtom :: forall a. a -> Effect (Atom a)
foreign import newObserver :: (Observer -> Effect Unit) -> Effect Observer
foreign import getAtoms :: Observer -> Effect (Array GenericAtom)
foreign import getObservers :: GenericAtom -> Effect (Array Observer)
foreign import getAtomValue :: forall a. Atom a -> Effect a
foreign import setAtomValue :: forall a. Atom a -> a -> Effect Unit
foreign import getObserverSignal :: Observer -> Effect (Observer -> Effect Unit)
foreign import getObserverCallbacks :: Observer -> Effect (Array (Effect Unit))
foreign import addObserverCallback :: Observer -> Effect Unit -> Effect Unit
foreign import clearObserverCallbacks :: Observer -> Effect Unit

toGenericAtom :: forall a. Atom a -> GenericAtom
toGenericAtom = unsafeCoerce

emptyObserver :: Effect Observer
emptyObserver = newObserver $ const $ pure unit

deferEffect :: Effect Unit -> Signal Unit
deferEffect callback = do
  obs <- ask
  liftEffect $ addObserverCallback obs callback

launchSignal :: Signal Unit -> Effect Observer
launchSignal (Signal signal) = do
  obs <- newObserver $ runReaderT signal
  runReaderT signal obs
  pure obs

launchSignal_ :: Signal Unit -> Effect Unit
launchSignal_ signal = launchSignal signal $> unit

stopObserver :: Observer -> Effect Unit
stopObserver obs = do
  atoms <- getAtoms obs
  for_ atoms \atom -> do
    disconnect obs atom

newSignal
  :: forall a. a -> Effect (Tuple (Signal a) ((a -> a) -> Effect Unit))
newSignal init = do
  atom <- newAtom init

  let
    signal = do
      obs <- ask

      liftEffect $ connect obs $ toGenericAtom atom
      deferEffect $ disconnect obs $ toGenericAtom atom

      liftEffect $ getAtomValue atom

    mod f = do
      observers <- getObservers $ toGenericAtom atom

      for_ observers \obs -> do
        callbacks <- getObserverCallbacks obs
        for_ callbacks identity
        clearObserverCallbacks obs

      v <- getAtomValue atom
      setAtomValue atom $ f v

      for_ observers \obs -> do
        sig <- getObserverSignal obs
        sig obs

  pure $ Tuple signal mod

stackSignal :: Signal Unit -> Signal Unit
stackSignal signal = do
  obs <- liftEffect $ launchSignal signal
  deferEffect $ stopObserver obs
