module Test.Main where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Jelly.Core.Aff (awaitBody)
import Jelly.Core.Data.Component (Component, el, textSig)
import Jelly.Core.Data.Hooks (hooks)
import Jelly.Core.Data.Prop ((:=))
import Jelly.Core.Data.Signal (Signal, launch, patch_, signal)
import Jelly.Core.Hooks.UseInterval (useInterval)
import Jelly.Core.Mount (mount_)

name :: Signal String
name = pure "Jelly"

helloEffect :: Signal (Effect (Effect Unit))
helloEffect = name <#> \s -> do
  log $ "Hello, " <> s <> "!"
  pure do
    log $ "Bye, " <> s <> "!"

main :: Effect Unit
main = do
  stop <- launch helloEffect
  stop

  launchAff_ do
    bodyMaybe <- awaitBody
    case bodyMaybe of
      Just body -> do
        liftEffect $ mount_ {} testComp body
      Nothing -> pure unit

testComp :: Component ()
testComp = el "div" [ "class" := "test" ] stateful

stateful :: Component ()
stateful = hooks do
  timeSig /\ timeAtom <- signal 0

  useInterval 1000 do
    patch_ timeAtom (_ + 1)

  pure $ textSig $ show <$> timeSig
