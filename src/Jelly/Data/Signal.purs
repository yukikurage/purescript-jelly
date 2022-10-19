module Jelly.Data.Signal
  ( Atom
  , Signal
  , modifyAtom
  , modifyAtom_
  , newAtom
  , newAtomEq
  , newState
  , newStateEq
  , readSignal
  , runSignal
  , runSignalWithoutInit
  , runSignalWithoutInit_
  , runSignal_
  , subscribe
  , writeAtom
  ) where

import Prelude

import Control.Apply (lift2)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (new, read, write)

foreign import data Atom :: Type -> Type
foreign import data Signal :: Type -> Type

foreign import newAtomImpl :: forall a. a -> Effect (Atom a)
foreign import newAtomEqImpl :: forall a. (a -> a -> Boolean) -> a -> Effect (Atom a)
foreign import subscribe :: forall a. Atom a -> Signal a
foreign import writeAtomImpl :: forall a. Atom a -> a -> Effect Unit
foreign import modifyAtomImpl :: forall a. Atom a -> (a -> a) -> Effect a
foreign import readSignalImpl :: forall a. Signal a -> Effect a
foreign import runSignalImpl :: Signal (Effect (Effect Unit)) -> Effect (Effect Unit)
foreign import mapImpl :: forall a b. (a -> b) -> Signal a -> Signal b
foreign import applyImpl :: forall a b. Signal (a -> b) -> Signal a -> Signal b
foreign import pureImpl :: forall a. a -> Signal a
foreign import bindImpl :: forall a b. Signal a -> (a -> Signal b) -> Signal b

instance Functor Signal where
  map = mapImpl

instance Apply Signal where
  apply = applyImpl

instance Applicative Signal where
  pure = pureImpl

instance Bind Signal where
  bind = bindImpl

instance Monad Signal

instance Semigroup a => Semigroup (Signal a) where
  append = lift2 append

instance Monoid a => Monoid (Signal a) where
  mempty = pure mempty

newAtom :: forall a m. MonadEffect m => a -> m (Atom a)
newAtom = liftEffect <<< newAtomImpl

newAtomEq :: forall a m. MonadEffect m => Eq a => a -> m (Atom a)
newAtomEq = liftEffect <<< newAtomEqImpl eq

writeAtom :: forall a m. MonadEffect m => Atom a -> a -> m Unit
writeAtom a = liftEffect <<< writeAtomImpl a

modifyAtom :: forall a m. MonadEffect m => Atom a -> (a -> a) -> m a
modifyAtom a = liftEffect <<< modifyAtomImpl a

modifyAtom_ :: forall a m. MonadEffect m => Atom a -> (a -> a) -> m Unit
modifyAtom_ a f = void $ modifyAtom a f

newState :: forall m a. MonadEffect m => a -> m (Signal a /\ Atom a)
newState init = liftEffect do
  atm <- newAtom init
  pure $ subscribe atm /\ atm

newStateEq :: forall m a. MonadEffect m => Eq a => a -> m (Signal a /\ Atom a)
newStateEq init = liftEffect do
  atm <- newAtomEq init
  pure $ subscribe atm /\ atm

readSignal :: forall a m. MonadEffect m => Signal a -> m a
readSignal = liftEffect <<< readSignalImpl

runSignal :: forall m. MonadEffect m => Signal (Effect (Effect Unit)) -> m (Effect Unit)
runSignal = liftEffect <<< runSignalImpl

runSignal_ :: forall m. MonadEffect m => Signal (Effect (Effect Unit)) -> m Unit
runSignal_ = void <<< runSignal

runSignalWithoutInit :: forall m. MonadEffect m => Signal (Effect (Effect Unit)) -> m (Effect Unit)
runSignalWithoutInit sig = do
  isInit <- liftEffect $ new true
  runSignal $ sig <#> \eff -> do
    isInit' <- read isInit
    if isInit' then do
      write false isInit
      mempty
    else eff

runSignalWithoutInit_ :: forall m. MonadEffect m => Signal (Effect (Effect Unit)) -> m Unit
runSignalWithoutInit_ = void <<< runSignalWithoutInit
