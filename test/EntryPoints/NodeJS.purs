module Test.EntryPoints.NodeJS where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Class.Platform (class NodeJS, runNodeJSApp)
import Jelly.NodeJS (render, writeToFile)
import Node.Process (exit)
import Test.Main (rootComponent)

main :: Effect Unit
main = runNodeJSApp nodeJSMain

nodeJSMain :: NodeJS => Effect Unit
nodeJSMain = launchAff_ do
  rendered <- liftEffect $ render rootComponent unit
  writeToFile "./public/index.html" $ rendered
  liftEffect $ exit 0
