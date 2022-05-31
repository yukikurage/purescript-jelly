module Jelly.Hooks.UseUnmountJelly where

import Prelude

import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Jelly (Jelly, addCleaner)
import Jelly.Data.Jelly.Class (liftJelly)

useUnmountJelly :: forall r. Jelly Unit -> Hooks r Unit
useUnmountJelly = liftJelly <<< addCleaner
