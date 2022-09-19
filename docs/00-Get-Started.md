# 00 Get Started

First, create HTML that will serve as a template.

```html
<!DOCTYPE html>
<html lang="ja">
  <head>
    <meta charset="utf-8" />
    <title>Jelly Example</title>
    <script src="index.js"></script>
  </head>
  <body>
    <div id="app"></div>
  </body>
</html>
```

Next, write the Component definition and the main function.

```purs
import Prelude

import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitQuerySelector)
import Jelly.Data.Component (Component)
import Jelly.El (el_, text)
import Jelly.RunJelly (runJelly)
import Web.DOM.ParentNode (QuerySelector(..))

main :: Effect Unit
main = launchAff_ do
  appElemMaybe <- awaitQuerySelector $ QuerySelector "#app"
  liftEffect $ traverse_ (runJelly component) appElemMaybe

component :: Component ()
component = el_ "div" do
  el_ "h1" do
    text $ pure "Hello, Jelly!"

```

Finally, bundle the app, generate `index.js`, and load the HTML file.

```html
<!DOCTYPE html>
<html lang="ja">
  <head>
    <meta charset="utf-8" />
    <title>Jelly Example</title>
    <script src="index.js"></script>
  </head>
  <body>
    <div id="app">
      <h1>Hello, Jelly!</h1>
    </div>
  </body>
</html>
```
