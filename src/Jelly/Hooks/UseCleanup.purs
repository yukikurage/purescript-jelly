module Jelly.Hooks.UseCleanup where

import Prelude

import Control.Monad.Writer (tell)
import Effect (Effect)
import Jelly.Data.Hooks (Hooks)

useCleanup :: forall context. Effect Unit -> Hooks context Unit
useCleanup = tell
