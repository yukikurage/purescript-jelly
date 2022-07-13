module Jelly.Hooks.UseMemo where

import Prelude

import Effect.Class (liftEffect)
import Jelly.Data.HookM (HookM)
import Jelly.Data.Signal (SignalM, disconnectSignal, newSignal, newSignalWithEq, readSignal)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

useMemo :: forall a. Eq a => SignalM a -> HookM (SignalM a)
useMemo signalM = do
  signal <- liftEffect $ newSignal signalM
  useUnmountEffect $ disconnectSignal signal
  pure $ readSignal signal

useMemoWithEq
  :: forall a. (a -> a -> Boolean) -> SignalM a -> HookM (SignalM a)
useMemoWithEq eq signalM = do
  signal <- liftEffect $ newSignalWithEq eq signalM
  useUnmountEffect $ disconnectSignal signal
  pure $ readSignal signal

useMemoWithoutEq :: forall a. SignalM a -> HookM (SignalM a)
useMemoWithoutEq = useMemoWithEq \_ _ -> false
