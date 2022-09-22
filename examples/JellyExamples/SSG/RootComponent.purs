module JellyExamples.SSG.RootComponent where

import Prelude

import Jelly.Core.Components (docTypeHTML, el_, text)
import Jelly.Core.Data.Component (Component)
import Jelly.SSG.Components (mainScript)
import Jelly.SSG.Data.GeneratorConfig (SsgContext)
import JellyExamples.SSG.Context (Context)
import JellyExamples.SSG.Page (Page)

rootComponent :: Component Context -> Component (SsgContext Page ())
rootComponent pageComponent = do
  docTypeHTML
  el_ "html" do
    el_ "head" do
      mainScript
    el_ "body" do
      el_ "h1" do
        text $ pure "🍮Hello, Jelly!"
      pageComponent
