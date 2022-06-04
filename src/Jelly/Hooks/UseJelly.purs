module Jelly.Hooks.UseJelly where

import Prelude

import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Jelly (Jelly, launchJelly, stopJelly)
import Jelly.Hooks.UseUnmountJelly (useUnmountJelly)

useJelly :: forall r. Jelly Unit -> Hooks r Unit
useJelly jelly = useUnmountJelly <<< stopJelly =<< launchJelly jelly
