module Test.EntryPoints.Browser where

import Prelude

import Effect (Effect)
import Effect.Aff (Milliseconds(..), delay, launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitDocument)
import Jelly.Browser (runJelly)
import Jelly.Class.Platform (class Browser, runBrowserApp)
import Test.Html (html)
import Test.Main (rootComponent)

main :: Effect Unit
main = runBrowserApp browserMain

browserMain :: Browser => Effect Unit
browserMain = launchAff_ do
  node <- awaitDocument
  delay $ Milliseconds 1000.0
  liftEffect $ runJelly (html rootComponent) unit node
