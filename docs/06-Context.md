# 06 Context

Context allows you to share values among components without having to bucket-relay values.

Here is an example

```purs
import Prelude

import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (makeComponent)
import Jelly.Core.Components (el_, provideContext, text)
import Jelly.Hooks.UseContext (useContext)

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
```

Thus, contextProvider provides a Context and useContext retrieves a Context.

The argument of type Component represents the type of Context.
