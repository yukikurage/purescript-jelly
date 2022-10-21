module Jelly.Hooks.UseInterval where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.Hooks (Hooks)
import Jelly.Hooks.UseCleanup (useCleanup)

useInterval :: forall context. Int -> Effect Unit -> Hooks context Unit
useInterval msc eff = do
  id <- liftEffect $ setInterval msc eff
  useCleanup $ clearInterval id
