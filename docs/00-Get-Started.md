# 00 Get Started

First, create HTML that will serve as a template.

```html
<!DOCTYPE html>
<html lang="ja">
  <head>
    <meta charset="utf-8" />
    <title>Jelly Example</title>
  </head>
  <body>
    <div id="app"></div>
    <script src="index.js"></script>
  </body>
</html>
```

Next, write the Component definition.

```purs
component :: Component Unit
component = el_ "h1" do
  text $ pure "Hello, Jelly!"
```

Finally, the main function mounts the component on the HTML `"app"` element.

```purs
main :: Effect Unit
main = runBrowserApp $ launchAff_ do
  appElemMaybe <- awaitQuerySelector $ QuerySelector "#app"
  liftEffect $ traverse_ (runJelly component unit) appElemMaybe
```

As a result, the following HTML is generated

```html
<!DOCTYPE html>
<html lang="ja">
  <head>
    <meta charset="utf-8" />
    <title>Jelly Example</title>
  </head>
  <body>
    <div id="app">
      <h1>Hello, Jelly!</h1>
    </div>
    <script src="index.js"></script>
  </body>
</html>
```
