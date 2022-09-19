module Test.ClientMain where

import Prelude

import Debug (traceM)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitDocument)
import Jelly.RunJelly (runJelly_)
import Jelly.Util (getPath)
import Test.Page (basePath, fromPath)
import Test.RootComponent (rootComponent)
import Web.HTML (window)

main :: Effect Unit
main = launchAff_ do
  node <- awaitDocument
  path <- liftEffect $ getPath basePath =<< window
  traceM path
  liftEffect $ runJelly_ (rootComponent $ fromPath path) node
