module Test.Main where

import Prelude

import Effect (Effect)
import Jelly.Data.Component (Component(..), NodeSpec(..), instantiate, on, render, (:=))
import Web.Event.Event (EventType(..))

foreign import setBodyInnerHTML :: String -> Effect Unit

main :: Effect Unit
main = do
  setBodyInnerHTML =<< render component

component :: Component
component = Component do
  textComponentInstance <- instantiate componentText
  pure $ NodeSpecElement
    { tagName: "div"
    , props:
        [ on (EventType "click") mempty
        , "class" := pure "container"
        ]
    , children: pure [ textComponentInstance ]
    , unmountEffect: mempty
    }

componentText :: Component
componentText = Component do
  pure $ NodeSpecText
    { text: pure "Hello World"
    , unmountEffect: mempty
    }
