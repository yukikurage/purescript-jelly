module Jelly.Data.Signal where

import Prelude

import Control.Safely (for_)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Ref (Ref, new, read, write)

foreign import data Receptor :: Type

foreign import data Signal :: Type

foreign import newReceptor :: Effect (Effect Unit) -> Effect Receptor

foreign import newSignal :: Effect Signal

foreign import connect :: Receptor -> Signal -> Effect Unit

foreign import disconnect :: Receptor -> Signal -> Effect Unit

foreign import getEffect :: Receptor -> Effect (Effect (Effect Unit))

foreign import getCallback :: Receptor -> Effect (Effect Unit)

foreign import setCallback :: Receptor -> Effect Unit -> Effect Unit

foreign import getReceptors :: Signal -> Effect (Array Receptor)

foreign import getSignals :: Receptor -> Effect (Array Signal)

data SignalInput a = SignalInput (Ref a) Signal

data SignalOutput a = SignalOutput (Receptor -> Effect Unit) (Effect a)

newtype SubscriptionId = SubscriptionId (Effect Unit)

instance Functor SignalOutput where
  map f (SignalOutput g e) = SignalOutput g (map f e)

instance Apply SignalOutput where
  apply (SignalOutput f e) (SignalOutput g e') = SignalOutput (\r -> f r *> g r)
    (apply e e')

instance Applicative SignalOutput where
  pure a = SignalOutput (\_ -> pure unit) $ pure a

newState :: forall a. a -> Effect (SignalOutput a /\ SignalInput a)
newState a = do
  ref <- new a
  signal <- newSignal

  let
    signalOutput = SignalOutput (\receptor -> connect receptor signal) $
      read ref

    signalInput = SignalInput ref signal

  pure $ signalOutput /\ signalInput

readState :: forall a. SignalOutput a -> Effect a
readState (SignalOutput _ e) = e

writeState :: forall a. SignalInput a -> a -> Effect Unit
writeState (SignalInput ref signal) a = do
  receptors <- getReceptors signal

  for_ receptors $ \receptor -> join $ getCallback receptor
  write a ref
  for_ receptors $ \receptor -> do
    callback <- join $ getEffect receptor
    setCallback receptor callback

modifyState :: forall a. SignalInput a -> (a -> a) -> Effect Unit
modifyState (SignalInput ref signal) f = do
  a <- read ref
  writeState (SignalInput ref signal) (f a)

subscribe
  :: forall a. SignalOutput a -> Effect (Effect Unit) -> Effect SubscriptionId
subscribe (SignalOutput registerFunc _) listener = do
  receptor <- newReceptor listener
  registerFunc receptor
  setCallback receptor =<< listener
  pure $ SubscriptionId do
    signals <- getSignals receptor
    for_ signals $ \signal -> disconnect receptor signal
    join $ getCallback receptor
