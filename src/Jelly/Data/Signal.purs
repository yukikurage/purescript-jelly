module Jelly.Data.Signal
  ( Atom
  , Signal
  , get
  , launch
  , launchWithoutInit
  , launchWithoutInit_
  , launch_
  , patch
  , patch_
  , send
  , signal
  , subscribe
  ) where

import Prelude

import Control.Apply (lift2)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (new, read, write)

foreign import data Atom :: Type -> Type
foreign import data Signal :: Type -> Type

type Listener a = a -> Effect (Effect Unit)

foreign import atomImpl :: forall a. a -> Effect (Atom a)
foreign import subscribe :: forall a. Atom a -> Signal a
foreign import sendImpl :: forall a. Atom a -> a -> Effect Unit
foreign import patchImpl :: forall a. Atom a -> (a -> a) -> Effect a
foreign import getImpl :: forall a. Signal a -> Effect a
foreign import runImpl :: Signal (Effect (Effect Unit)) -> Effect (Effect Unit)
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

instance Semigroup a => Semigroup (Signal a) where
  append = lift2 append

instance Monoid a => Monoid (Signal a) where
  mempty = pure mempty

atom :: forall a m. MonadEffect m => a -> m (Atom a)
atom = liftEffect <<< atomImpl

send :: forall a m. MonadEffect m => Atom a -> a -> m Unit
send a = liftEffect <<< sendImpl a

patch :: forall a m. MonadEffect m => Atom a -> (a -> a) -> m a
patch a = liftEffect <<< patchImpl a

patch_ :: forall a m. MonadEffect m => Atom a -> (a -> a) -> m Unit
patch_ a f = void $ patch a f

signal :: forall m a. MonadEffect m => a -> m (Signal a /\ Atom a)
signal init = liftEffect do
  atm <- atom init
  pure $ subscribe atm /\ atm

get :: forall a m. MonadEffect m => Signal a -> m a
get = liftEffect <<< getImpl

launch :: forall m. MonadEffect m => Signal (Effect (Effect Unit)) -> m (Effect Unit)
launch = liftEffect <<< runImpl

launch_ :: forall m. MonadEffect m => Signal (Effect (Effect Unit)) -> m Unit
launch_ = void <<< launch

launchWithoutInit :: forall m. MonadEffect m => Signal (Effect (Effect Unit)) -> m (Effect Unit)
launchWithoutInit sig = do
  isInit <- liftEffect $ new true
  launch $ sig <#> \eff -> do
    isInit' <- read isInit
    if isInit' then do
      write false isInit
      mempty
    else eff

launchWithoutInit_ :: forall m. MonadEffect m => Signal (Effect (Effect Unit)) -> m Unit
launchWithoutInit_ = void <<< launchWithoutInit
