module Jelly.Hooks.UseInterval where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.Hook (Hook)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

useInterval :: forall r. Int -> Effect Unit -> Hook r Unit
useInterval time effect = do
  id <- liftEffect $ setInterval time effect

  useUnmountEffect $ clearInterval id
