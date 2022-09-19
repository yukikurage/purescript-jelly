module JellyExamples.SSG.RootComponent where

import Prelude

import Jelly.Data.Component (Component)
import Jelly.Data.Prop ((:=))
import Jelly.El (docTypeHTML, el, el_, emptyC, text)
import Test.Context (Context)

rootComponent :: Component Context
rootComponent = do
  docTypeHTML
  el_ "html" do
    el_ "head" do
      el "script"
        [ "defer" := true, "type" := "text/javascript", "src" := "./index.js" ]
        emptyC
    el_ "body" do
      el_ "h1" do
        text $ pure "🍮Hello, Jelly!"
