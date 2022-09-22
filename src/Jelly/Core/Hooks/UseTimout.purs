module Jelly.Core.Hooks.UseTimeout where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Timer (clearTimeout, setTimeout)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Hooks.UseUnmountEffect (useUnmountEffect)

useTimeout :: forall context. Int -> Effect Unit -> Hooks context Unit
useTimeout msc eff = do
  id <- liftEffect $ setTimeout msc eff
  useUnmountEffect $ clearTimeout id
