module JellyExamples.Context where

import Prelude

import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (makeComponent)
import Jelly.El (el_, provideContext, text)
import Jelly.Hooks.UseContext (useContext)

componentParent :: Component ()
componentParent = provideContext { someContext: "text" } $ el_ "div" do
  componentFirstChild

componentFirstChild :: Component (someContext :: String)
componentFirstChild = el_ "div" do
  componentSecondChild

componentSecondChild :: Component (someContext :: String)
componentSecondChild = makeComponent do
  { someContext } <- useContext

  pure $ el_ "div" do
    text $ pure someContext
