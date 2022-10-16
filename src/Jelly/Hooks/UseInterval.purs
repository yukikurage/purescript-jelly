module Jelly.Hooks.UseInterval where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.Hooks (Hooks)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

useInterval :: forall context. Int -> Effect Unit -> Hooks context Unit
useInterval msc eff = do
  id <- liftEffect $ setInterval msc eff
  useUnmountEffect $ clearInterval id