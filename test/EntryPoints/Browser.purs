module Test.EntryPoints.Browser where

import Prelude

import Effect (Effect)
import Jelly.Class.Platform (runBrowserApp)
import Test.Main (browserMain)

main :: Effect Unit
main = runBrowserApp browserMain
