# 07 Static Site Generator

Jelly supports SSG.

SSG works by the following process

- Build
  - Generate and export HTML from components
  - Bundle client-side code using spago
- Browser
  - Display generated HTML
  - Attach handler by client-side script (Hydration)

## Make root component

To use Jelly's SSG, you need to create a document root component.

```purs
module JellyExamples.SSG.RootComponent where

import Prelude

import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Prop ((:=))
import Jelly.Core.Components (docTypeHTML, el, el_, emptyC, text)
import Test.Context (Context)

rootComponent :: Component Context
rootComponent = do
  docTypeHTML
  el_ "html" do
    el_ "head" do
      el "script"
        [ "defer" := true, "type" := "text/javascript", "src" := "/index.js" ]
        emptyC
    el_ "body" do
      el_ "h1" do
        text $ pure "🍮Hello, Jelly!"

```

This would generate HTML like the following

```html
<!DOCTYPE html>
<html>
  <head>
    <script defer type="text/javascript" src="./index.js"></script>
  </head>
  <body>
    <h1>🍮Hello, Jelly!</h1>
  </body>
</html>
```

## Make client-side entry point

Next, create client-side entry points.

Note that the files need to be separated.

```purs
module JellyExamples.SSG.ClientMain where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Core.Aff (awaitDocument)
import Jelly.mount (mount)
import Test.RootComponent (rootComponent)

main :: Effect Unit
main = launchAff_ do
  node <- awaitDocument
  liftEffect $ mount rootComponent node
```

## Make Main module

Finally, create a Main module.

In the generator settings, specify the name of the module for the client-side entry point you just created, the output destination for index.html and index.js, and the root component.

```purs
module JellyExamples.SSG.Main where

import Prelude

import Effect (Effect)
import Jelly.SSG.Generator (GeneratorSettings(..), generate)
import JellyExamples.SSG.RootComponent (rootComponent)

generatorSettings :: GeneratorSettings
generatorSettings = GeneratorSettings
{ clientMain: "JellyExamples.SSG.ClientMain"
, output: "public"
, component: rootComponent
}

main :: Effect Unit
main = generate generatorSettings
```

## Run SSG

```
npx spago run --main JellyExamples.SSG.Main
```

When the Main module is executed, public/index.html and public/index.js are generated.
