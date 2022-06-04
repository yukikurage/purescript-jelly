module Jelly.Hooks.UseUnmountJelly where

import Prelude

import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Jelly (Jelly, addCleaner, alone)

useUnmountJelly :: forall r. Jelly Unit -> Hooks r Unit
useUnmountJelly = addCleaner <<< alone
