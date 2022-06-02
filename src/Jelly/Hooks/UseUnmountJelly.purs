module Jelly.Hooks.UseUnmountJelly where

import Prelude

import Control.Monad.Reader (ask)
import Effect.Class (liftEffect)
import Effect.Ref (read, write)
import Jelly.Data.Hooks (Hooks)
import Jelly.Data.Jelly (Jelly, alone)

useUnmountJelly :: forall r. Jelly Unit -> Hooks r Unit
useUnmountJelly jelly = do
  { unmountEffectRef } <- ask
  unmountEffect <- liftEffect $ read unmountEffectRef
  liftEffect $ write (unmountEffect *> alone jelly) unmountEffectRef
