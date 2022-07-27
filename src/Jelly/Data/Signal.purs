module Jelly.Data.Signal where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.Writer (class MonadTell, class MonadWriter, WriterT, runWriterT)
import Control.Safely (for_)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)

foreign import data Signal :: Type -> Type

foreign import data Observer :: Type

foreign import newSignalImpl
  :: forall a
   . a
  -> Effect (Signal a)

foreign import newObserverImpl
  :: forall a
   . (Observer -> Effect a)
  -> Effect Observer

foreign import disconnectObserverImpl :: Observer -> Effect Unit

foreign import readSignalImpl
  :: forall a. Observer -> Signal a -> Effect a

foreign import modifySignalImpl
  :: forall a. (a -> a -> Boolean) -> Signal a -> (a -> a) -> Effect Unit

-- | SignalM モナドは Signal の値を更新するためのモナド
-- | 基本的には Effect だが、Reader モナドによりいつでも更新対象の Signal をとってくることができる
-- | したがって、動的な依存関係の自動解決が可能となっている
newtype SignalM a = SignalM
  (ReaderT Observer (WriterT (Array (Effect Unit)) Effect) a)

derive newtype instance Functor SignalM
derive newtype instance Applicative SignalM
derive newtype instance Apply SignalM
derive newtype instance Bind SignalM
derive newtype instance Monad SignalM
derive newtype instance MonadAsk Observer SignalM
derive newtype instance MonadReader Observer SignalM
derive newtype instance MonadRec SignalM
derive newtype instance MonadTell (Array (Effect Unit)) SignalM
derive newtype instance MonadWriter (Array (Effect Unit)) SignalM
derive newtype instance MonadEffect SignalM

runSignalM
  :: forall a. SignalM a -> Observer -> Effect (Tuple a (Effect Unit))
runSignalM (SignalM m) obs = do
  Tuple a callbacks <- runWriterT (runReaderT m obs)
  pure $ Tuple a do
    for_ callbacks identity

newSignal :: forall a. a -> Effect (Signal a)
newSignal = newSignalImpl

launchSignalM :: SignalM Unit -> Effect Observer
launchSignalM signalM = do
  let
    effect = \observer -> do
      Tuple _ callback <- runSignalM signalM observer
      pure callback
  newObserverImpl effect

disconnectObserver :: Observer -> Effect Unit
disconnectObserver = disconnectObserverImpl

modifySignal
  :: forall a. Eq a => Signal a -> (a -> a) -> Effect Unit
modifySignal signal f = modifySignalImpl eq signal f

modifySignalForce :: forall a. Signal a -> (a -> a) -> Effect Unit
modifySignalForce signal f = modifySignalImpl (\_ _ -> false) signal f

writeSignal :: forall a. Eq a => Signal a -> a -> Effect Unit
writeSignal signal a = modifySignal signal (const a)

writeSignalForce :: forall a. Signal a -> a -> Effect Unit
writeSignalForce signal a = modifySignalForce signal (const a)

readSignal :: forall a. Signal a -> SignalM a
readSignal signal = do
  observer <- ask
  liftEffect $ readSignalImpl observer signal
