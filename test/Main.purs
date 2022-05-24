module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Jelly.Data.Jelly (newJelly)
import Jelly.Data.Props (on)
import Jelly.Hooks.DOM (el, text)
import Jelly.RunApp (runApp)

main :: Effect Unit
main = runApp do
  counterValue /\ modifyCounterValue <- newJelly 0

  el "div" []
    [ el "button"
        [ on "click" \_ -> modifyCounterValue (_ + 1)
        ]
        [ text $ pure "+" ]
    , el "div" [] $ [ text $ show <$> counterValue ]
    , el "button"
        [ on "click" \_ -> modifyCounterValue (_ - 1)
        ]
        [ text $ pure "-" ]
    ]
