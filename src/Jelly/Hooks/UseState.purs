module Jelly.Hooks.UseState where

import Prelude

import Data.Tuple.Nested (type (/\))
import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Jelly (Jelly, newJelly)

useState
  :: forall r a. Eq a => a -> Hooks r (Jelly a /\ ((a -> a) -> Jelly Unit))
useState = newJelly
