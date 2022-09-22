module JellyExamples.Context where

import Prelude

import Jelly.Core.Components (contextProvider, el_, text)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (makeComponent)
import Jelly.Core.Hooks.UseContext (useContext)

componentParent :: Component ()
componentParent = contextProvider { someContext: "text" } $ el_ "div" do
  componentFirstChild

componentFirstChild :: Component (someContext :: String)
componentFirstChild = el_ "div" do
  componentSecondChild

componentSecondChild :: Component (someContext :: String)
componentSecondChild = makeComponent do
  { someContext } <- useContext

  pure $ el_ "div" do
    text $ pure someContext
