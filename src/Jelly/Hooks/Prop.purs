module Jelly.Hooks.Prop where

import Prelude

import Control.Monad.Reader (ask)
import Control.Monad.ST.Global (toEffect)
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Foreign.Object.ST as FOST
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal)

setProp :: forall r. String -> Signal String -> Hook r Unit
setProp key valueSig = do
  { propsRef } <- ask
  _ <- liftEffect $ toEffect $ FOST.poke key [ valueSig ] propsRef
  pure unit

infix 1 setProp as :=

appendProp :: forall r. String -> Signal String -> Hook r Unit
appendProp key valueSig = do
  { propsRef } <- ask
  currentMaybe <- liftEffect $ toEffect $ FOST.peek key propsRef
  case currentMaybe of
    Nothing -> do
      _ <- liftEffect $ toEffect $ FOST.poke key [ valueSig ] propsRef
      pure unit
    Just current -> do
      _ <- liftEffect $ toEffect $ FOST.poke key (current <> [ valueSig ])
        propsRef
      pure unit

infix 1 appendProp as :+
