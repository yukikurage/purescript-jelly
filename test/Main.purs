module Test.Main where

import Prelude

import Control.Monad.Trans.Class (lift)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Milliseconds(..), delay, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.HookM (HookM, runHookM)
import Jelly.Data.JellyM (runAlone)
import Jelly.Hooks.DOM (text)
import Jelly.Hooks.UseEffect (useEffect)
import Jelly.Hooks.UseState (useState)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)
import Jelly.RunApp (runApp)
import Web.DOM (Node)

main :: Effect Unit
main = launchAff_ do
  {- Dependencies Test -}
  _ /\ unmount <- liftEffect $ runHookM dependenciesTest

  delay $ Milliseconds 1000.0

  log "setTimeout called"
  liftEffect $ unmount

  {- App Test -}

  liftEffect $ runApp appTest

dependenciesTest :: HookM Effect Unit
dependenciesTest = do
  lift $ log "hooksTest called"

  getState /\ modifyState <- useState 0

  useEffect do
    lift $ log "useEffect called"
    state <- getState
    lift $ log $ "state: " <> show state
    pure $ pure unit

  id <- lift $ setInterval 200 $ runAlone do
    lift $ log "setInterval called"
    modifyState (_ + 1)

  useUnmountEffect do
    lift $ log "useUnmountEffect called"
    lift $ clearInterval id

  pure unit

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
