module Test.AppTest where

import Prelude

import Control.Monad.Trans.Class (lift)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.HookM (HookM)
import Jelly.Data.JellyM (runAlone)
import Jelly.Hooks.DOM (text)
import Jelly.Hooks.UseState (useState)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)
import Web.DOM (Node)

appTest :: HookM Effect Node
appTest = do
  lift $ log "appTest called"

  getState /\ modifyState <- useState "C"

  id <- lift $ setInterval 200 $ runAlone do
    lift $ log "setInterval called"
    modifyState (_ <> "+")

  useUnmountEffect do
    lift $ clearInterval id

  text getState
