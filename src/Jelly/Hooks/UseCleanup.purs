module Jelly.Hooks.UseCleanup where

import Prelude

import Control.Monad.Writer (tell)
import Effect (Effect)
import Jelly.Data.Hooks (Hooks)

useUnmount :: forall context. Effect Unit -> Hooks context Unit
useUnmount = tell
