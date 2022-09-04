module Test.Main where

import Prelude

import Effect (Effect)
import Jelly.Data.Component (Component(..), instantiate, on, render, (:=))
import Web.Event.Event (EventType(..))

foreign import setBodyInnerHTML :: String -> Effect Unit

main :: Effect Unit
main = do
  setBodyInnerHTML =<< render component

component :: Component
component = ComponentElement do
  textComponentInstance <- instantiate componentText
  pure
    { tagName: "div"
    , props:
        [ on (EventType "click") mempty
        , "class" := pure "container"
        ]
    , children: pure [ textComponentInstance ]
    }

componentText :: Component
componentText = ComponentText "Hello World"
