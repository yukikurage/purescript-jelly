module Jelly.Hooks.UseUnmountEffect where

import Prelude

import Control.Monad.Writer (tell)
import Effect (Effect)
import Jelly.Data.HookM (HookM)

useUnmountEffect :: Effect Unit -> HookM Unit
useUnmountEffect effect = tell [ effect ]
