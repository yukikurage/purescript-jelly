module Jelly.Core.Hooks.UseInterval where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Core.Hooks.UseUnmountEffect (useUnmountEffect)

useInterval :: forall context. Int -> Effect Unit -> Hooks context Unit
useInterval msc eff = do
  id <- liftEffect $ setInterval msc eff
  useUnmountEffect $ clearInterval id
