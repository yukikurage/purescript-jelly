module Jelly.Hooks.UseJelly where

import Prelude

import Jelly.Data.Hooks (Hooks, liftJelly)
import Jelly.Data.Jelly (Jelly, launchJelly_)

useJelly :: forall r. Jelly Unit -> Hooks r Unit
useJelly x = liftJelly $ launchJelly_ x
