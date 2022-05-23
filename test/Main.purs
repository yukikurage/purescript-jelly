module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Jelly.Data.HookM (HookM)
import Jelly.Data.Props (on)
import Jelly.Hooks.DOM (el, text)
import Jelly.Hooks.UseState (useState)
import Jelly.RunApp (runApp)
import Web.DOM (Node)

main :: Effect Unit
main = runApp appTest unit

appTest :: forall r. HookM r Node
appTest = do
  counterValue /\ modifyCounterValue <- useState 0

  el "div" []
    [ pure $ el "button"
        [ on "click" \_ -> modifyCounterValue (_ + 1)
        ]
        [ pure $ text $ pure "+" ]
    , pure $ el "div" [] $ [ pure $ text $ show <$> counterValue ]
    , pure $ el "button"
        [ on "click" \_ -> modifyCounterValue (_ - 1)
        ]
        [ pure $ text $ pure "-" ]
    ]
