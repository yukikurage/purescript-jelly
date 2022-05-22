module Test.Main where

import Prelude

import Control.Monad.Trans.Class (lift)
import Data.Foldable (sequence_)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Timer (clearInterval, setInterval, setTimeout)
import Jelly.Data.Emitter (emit, newEmitter)
import Jelly.Data.HookM (HookM, runHookM)
import Jelly.Data.JellyM (runAlone)
import Jelly.Hooks.UseEffect (useEffect)
import Jelly.Hooks.UseState (useState)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

main :: Effect Unit
main = do
  emitter <- newEmitter
  runHookM hooksTest emitter

  _ <- setTimeout 2000 $ do
    log "setTimeout called"
    sequence_ $ emit emitter unit
    newEmitter <- newEmitter
    runHookM hooksTest newEmitter

  pure unit

hooksTest :: HookM Effect Unit
hooksTest = do
  lift $ log "hooksTest called"

  getState /\ modifyState <- useState 0

  useEffect do
    lift $ log "useEffect called"
    state <- getState
    lift $ log $ "state: " <> show state
    pure $ pure unit

  id <- lift $ setInterval 500 $ runAlone do
    lift $ log "setInterval called"
    modifyState (_ + 1)

  useUnmountEffect do
    lift $ log "useUnmountEffect called"
    lift $ clearInterval id

  pure unit
