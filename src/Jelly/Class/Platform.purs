module Jelly.Class.Platform
  ( class Browser
  , class NodeJS
  , runBrowserApp
  , runNodeJSApp
  ) where

class NodeJS
class Browser

foreign import runAppImpl :: forall a b. a -> b

runBrowserApp :: forall a. (Browser => a) -> a
runBrowserApp = runAppImpl

runNodeJSApp :: forall a. (NodeJS => a) -> a
runNodeJSApp = runAppImpl
