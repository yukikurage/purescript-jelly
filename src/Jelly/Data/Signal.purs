module Jelly.Data.Signal
  ( Atom
  , Signal
  , launchSignal
  , launchSignalEq
  , launchSignalEq_
  , launchSignal_
  , modifyAtom
  , modifyAtom_
  , newAtom
  , newAtomEq
  , newState
  , newStateEq
  , readSignal
  , runSignal
  , runSignalWithoutInit
  , subscribe
  , unwrapAffSignal
  , unwrapAffSignalEq
  , unwrapEffectSignal
  , unwrapEffectSignalEq
  , writeAtom
  ) where

import Prelude

import Control.Apply (lift2)
import Data.Tuple (fst, snd)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (modify, new, read, write)

foreign import data Atom :: Type -> Type
foreign import data Signal :: Type -> Type

foreign import newAtomImpl :: forall a. a -> Effect (Atom a)
foreign import newAtomEqImpl :: forall a. (a -> a -> Boolean) -> a -> Effect (Atom a)
foreign import subscribe :: forall a. Atom a -> Signal a
foreign import writeAtomImpl :: forall a. Atom a -> a -> Effect Unit
foreign import modifyAtomImpl :: forall a. Atom a -> (a -> a) -> Effect a
foreign import readSignalImpl :: forall a. Signal a -> Effect a
foreign import runSignalImpl
  :: forall a
   . (a -> a -> Boolean)
  -> Signal (Effect { result :: a, cleanup :: Effect Unit })
  -> Effect { result :: Signal a, cleanup :: Effect Unit }

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

launchSignal
  :: forall m a. MonadEffect m => Signal (Effect (a /\ Effect Unit)) -> m (Signal a /\ Effect Unit)
launchSignal sig = liftEffect do
  { result, cleanup } <- runSignalImpl (\_ _ -> false) $ sig <#> \eff -> do
    result /\ cleanup <- eff
    pure { result, cleanup }
  pure $ result /\ cleanup

launchSignal_ :: forall m a. MonadEffect m => Signal (Effect (a /\ Effect Unit)) -> m (Signal a)
launchSignal_ sig = fst <$> launchSignal sig

launchSignalEq
  :: forall m a
   . MonadEffect m
  => Eq a
  => Signal (Effect (a /\ Effect Unit))
  -> m (Signal a /\ Effect Unit)
launchSignalEq sig = liftEffect do
  { result, cleanup } <- runSignalImpl eq $ sig <#> \eff -> do
    result /\ cleanup <- eff
    pure { result, cleanup }
  pure $ result /\ cleanup

launchSignalEq_
  :: forall m a. MonadEffect m => Eq a => Signal (Effect (a /\ Effect Unit)) -> m (Signal a)
launchSignalEq_ sig = fst <$> launchSignalEq sig

runSignal :: forall m. MonadEffect m => Signal (Effect (Effect Unit)) -> m (Effect Unit)
runSignal sig = snd <$> launchSignalEq (sig <#> (map (unit /\ _)))

runSignalWithoutInit :: forall m. MonadEffect m => Signal (Effect (Effect Unit)) -> m (Effect Unit)
runSignalWithoutInit sig = do
  isInit <- liftEffect $ new true
  runSignal $ sig <#> \eff -> do
    isInit' <- read isInit
    if isInit' then do
      write false isInit
      mempty
    else eff

unwrapEffectSignal :: forall m a. MonadEffect m => Signal (Effect a) -> m (Signal a /\ Effect Unit)
unwrapEffectSignal sig = launchSignal $ sig <#> (map (_ /\ pure unit))

unwrapEffectSignalEq
  :: forall m a. MonadEffect m => Eq a => Signal (Effect a) -> m (Signal a /\ Effect Unit)
unwrapEffectSignalEq sig = launchSignalEq $ sig <#> (map (_ /\ pure unit))

unwrapAffSignal :: forall m a. MonadEffect m => a -> Signal (Aff a) -> m (Signal a /\ Effect Unit)
unwrapAffSignal initial sig = do
  vSig /\ vAtom <- newState initial
  currentRef <- liftEffect $ new 0
  cleanup <- runSignal $ sig <#> \aff -> do
    current <- modify (_ + 1) currentRef
    launchAff_ do
      v <- aff
      finished <- liftEffect $ read currentRef
      if current == finished then do
        writeAtom vAtom v
      else pure unit
    mempty
  pure $ vSig /\ cleanup

unwrapAffSignalEq
  :: forall m a. MonadEffect m => Eq a => a -> Signal (Aff a) -> m (Signal a /\ Effect Unit)
unwrapAffSignalEq initial sig = do
  vSig /\ vAtom <- newStateEq initial
  currentRef <- liftEffect $ new 0
  cleanup <- runSignal $ sig <#> \aff -> do
    current <- modify (_ + 1) currentRef
    launchAff_ do
      v <- aff
      finished <- liftEffect $ read currentRef
      if current == finished then do
        writeAtom vAtom v
      else pure unit
    mempty
  pure $ vSig /\ cleanup