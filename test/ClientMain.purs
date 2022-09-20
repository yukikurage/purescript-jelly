module Test.ClientMain where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitDocument)
import Jelly.RunJelly (runJelly_)
import Jelly.Util (pathToArray)
import Test.Page (fromPath)
import Test.RootComponent (rootComponent)
import Web.HTML (window)
import Web.HTML.Location (pathname)
import Web.HTML.Window (location)

main :: Effect Unit
main = launchAff_ do
  node <- awaitDocument
  path <- liftEffect $ pathname =<< location =<< window
  liftEffect $ runJelly_ (rootComponent $ fromPath $ pathToArray path) node
