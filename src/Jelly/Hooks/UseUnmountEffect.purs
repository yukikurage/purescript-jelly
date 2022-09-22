module Jelly.Hooks.UseUnmountEffect where

import Prelude

import Control.Monad.Writer (tell)
import Effect (Effect)
import Jelly.Core.Data.Hooks (Hooks)

useUnmountEffect :: forall context. Effect Unit -> Hooks context Unit
useUnmountEffect unmountEffect = tell { unmountEffect }
