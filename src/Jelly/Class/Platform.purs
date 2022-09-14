module Jelly.Class.Platform where

import Prelude

import Effect.Unsafe (unsafePerformEffect)
import Unsafe.Coerce (unsafeCoerce)

class NodeJS
class Browser

runBrowserApp :: forall a. (Browser => a) -> a
runBrowserApp = unsafePerformEffect <<< unsafeCoerce

runNodeJSApp :: forall a. (NodeJS => a) -> a
runNodeJSApp = unsafePerformEffect <<< unsafeCoerce
