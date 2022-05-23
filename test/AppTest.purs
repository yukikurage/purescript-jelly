module Test.AppTest where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.HookM (HookM)
import Jelly.Data.JellyM (alone)
import Jelly.Hooks.DOM (text)
import Jelly.Hooks.UseState (useState)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)
import Web.DOM (Node)

appTest :: HookM Aff Node
appTest = do
  getState /\ modifyState <- useState "C"

  id <- liftEffect $ setInterval 200 $ alone do
    liftEffect $ modifyState (_ <> "+")

  useUnmountEffect do
    liftEffect $ clearInterval id

  text getState
