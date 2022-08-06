module Jelly.Hooks.UseTimeout where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Timer (clearTimeout, setTimeout)
import Jelly.Data.Hook (Hook, useUnmountEffect)

useTimeout :: forall r. Int -> Effect Unit -> Hook r Unit
useTimeout time effect = do
  id <- liftEffect $ setTimeout time effect

  useUnmountEffect $ clearTimeout id
