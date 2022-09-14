module Test.EntryPoints.Browser where

import Prelude

import Control.Safely (traverse_)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitQuerySelector)
import Jelly.Browser (runJelly)
import Jelly.Class.Platform (class Browser, runBrowserApp)
import Test.Main (rootComponent)
import Web.DOM.ParentNode (QuerySelector(..))

main :: Effect Unit
main = runBrowserApp browserMain

browserMain :: Browser => Effect Unit
browserMain = launchAff_ do
  elem <- awaitQuerySelector $ QuerySelector "#root"
  liftEffect $ traverse_ (runJelly rootComponent unit) elem
