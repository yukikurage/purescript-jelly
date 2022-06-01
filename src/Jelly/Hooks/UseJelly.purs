module Jelly.Hooks.UseJelly where

import Prelude

import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Jelly (Jelly, launchJelly_)
import Jelly.Data.Jelly.Class (liftJelly)

useJelly :: forall r. Jelly Unit -> Hooks r Unit
useJelly x = liftJelly $ launchJelly_ x
