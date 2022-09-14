module Test.EntryPoints.NodeJS where

import Prelude

import Effect (Effect)
import Jelly.Class.Platform (runNodeJSApp)
import Test.Main (nodeJSMain)

main :: Effect Unit
main = runNodeJSApp nodeJSMain
