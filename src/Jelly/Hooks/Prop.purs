module Jelly.Hooks.Prop where

import Prelude

import Control.Monad.Reader (ask)
import Effect.Class (liftEffect)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal)
import Jelly.Hooks.UseSignal (useSignal)
import Web.DOM.Element (setAttribute)

prop :: forall r. String -> Signal String -> Hook r Unit
prop key valueSig = do
  { parentElement } <- ask
  useSignal do
    value <- valueSig
    liftEffect $ setAttribute key value parentElement

infix 1 prop as :=
