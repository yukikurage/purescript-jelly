module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Jelly.Data.Jelly (newJelly)
import Jelly.Data.Props (on)
import Jelly.HTML as H
import Jelly.RunApp (runApp)

main :: Effect Unit
main = runApp do
  counterValue /\ modifyCounterValue <- newJelly 0

  H.div []
    [ H.button
        [ on "click" \_ -> modifyCounterValue (_ + 1)
        ]
        [ H.text $ pure "+" ]
    , H.div [] [ H.text $ show <$> counterValue ]
    , H.button
        [ on "click" \_ -> modifyCounterValue (_ - 1)
        ]
        [ H.text $ pure "-" ]
    ]
