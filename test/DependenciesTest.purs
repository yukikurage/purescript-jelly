module Test.DependenciesTest where

import Prelude

import Control.Monad.Trans.Class (lift)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.HookM (HookM)
import Jelly.Data.JellyM (runAlone)
import Jelly.Hooks.UseEffect (useEffect)
import Jelly.Hooks.UseState (useState)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

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
