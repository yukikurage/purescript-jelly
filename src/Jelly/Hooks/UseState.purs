module Jelly.Hooks.UseState where

import Prelude

import Data.Tuple.Nested (type (/\))
import Effect.Class (class MonadEffect)
import Jelly.Data.Jelly (Jelly, newJelly)

useState
  :: forall m a
   . MonadEffect m
  => Eq a
  => a
  -> m (Jelly a /\ ((a -> a) -> Jelly Unit))
useState = newJelly
