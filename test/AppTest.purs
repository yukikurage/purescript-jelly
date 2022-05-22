module Test.AppTest where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.HookM (HookM)
import Jelly.Data.JellyM (runAlone)
import Jelly.Hooks.DOM (text)
import Jelly.Hooks.UseListener (useListener)
import Jelly.Hooks.UseState (useState)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)
import Web.DOM (Node)

appTest :: HookM Aff Node
appTest = do
  log "appTest called"

  getState /\ modifyState <- useState "C"

  listener <- useListener $ \_ -> do
    modifyState (_ <> "+")

  id <- liftEffect $ setInterval 200 $ do
    listener unit

  useUnmountEffect do
    liftEffect $ clearInterval id

  text getState
