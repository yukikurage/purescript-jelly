module Jelly.Hooks.UseUnmountJelly where

import Prelude

import Jelly.Data.Hooks (Hooks, liftJelly)
import Jelly.Data.Jelly (Jelly, addCleaner)

useUnmountJelly :: forall r. Jelly Unit -> Hooks r Unit
useUnmountJelly = liftJelly <<< addCleaner
