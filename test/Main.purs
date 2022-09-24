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
import Jelly.Core.Data.Signal (modifyAtom_, signal)
import Jelly.Core.Mount (mount)
import Jelly.Core.Render (render)
import Web.DOM.Element as Element
import Web.DOM.ParentNode (QuerySelector(..))

main :: Effect Unit
main = launchAff_ do
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
    modifyAtom_ timeAtom (_ + 1)

  pure $ text $ show <$> timeSig
