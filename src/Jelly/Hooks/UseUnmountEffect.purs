module Jelly.Hooks.UseUnmountEffect where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.ST.Global (toEffect)
import Data.Array.ST (push)
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)

useUnmountEffect :: forall r. Effect Unit -> Hook r Unit
useUnmountEffect unmountEffect = do
  { unmountEffectsRef } <- ask
  liftEffect $ toEffect $ push unmountEffect unmountEffectsRef $> unit
