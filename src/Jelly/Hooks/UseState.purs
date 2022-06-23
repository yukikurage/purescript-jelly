module Jelly.Hooks.UseState where

import Effect.Class (class MonadEffect)
import Jelly.Data.Jelly (JellyRef, new)

useState :: forall m a. MonadEffect m => a -> m (JellyRef a)
useState = new
