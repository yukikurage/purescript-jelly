module Jelly.Hooks.UseTimeout where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Timer (clearTimeout, setTimeout)
import Jelly.Data.Hooks (Hooks)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

useTimeout :: forall context. Int -> Effect Unit -> Hooks context Unit
useTimeout msc eff = do
  id <- liftEffect $ setTimeout msc eff
  useUnmountEffect $ clearTimeout id
