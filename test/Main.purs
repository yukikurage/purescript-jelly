module Test.Main where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Timer (setInterval)
import Jelly.Core.Aff (awaitQuerySelector)
import Jelly.Core.Data.Component (Component, el, text)
import Jelly.Core.Data.Hooks (hooks)
import Jelly.Core.Data.Prop ((:=))
import Jelly.Core.Data.Signal (Signal, patch_, run, signal)
import Jelly.Core.Mount (mount)
import Jelly.Core.Render (render)
import Web.DOM.Element as Element
import Web.DOM.ParentNode (QuerySelector(..))

name :: Signal String
name = pure "Jelly"

helloEffect :: Signal (Effect (Effect Unit))
helloEffect = name <#> \s -> do
  log $ "Hello, " <> s <> "!"
  pure do
    log $ "Bye, " <> s <> "!"

main :: Effect Unit
main = do
  stop <- run helloEffect
  stop

  launchAff_ do
    app <- awaitQuerySelector $ QuerySelector "#app"

    case app of
      Just el -> do
        liftEffect $ void $ mount {} testComp $ Element.toNode el
        log <=< liftEffect $ render {} testComp

      Nothing -> mempty

testComp :: Component ()
testComp = el "div" [ "class" := "test" ] stateful

stateful :: Component ()
stateful = hooks do
  timeSig /\ timeAtom <- signal 0

  _ <- liftEffect $ setInterval 1000 do
    patch_ timeAtom (_ + 1)

  pure $ text $ show <$> timeSig
