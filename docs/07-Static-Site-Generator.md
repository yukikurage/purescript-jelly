# 07 Static Site Generator

Jelly supports SSG.

SSG works by the following process

- Build
  - Generate and export HTML from components
  - Bundle client-side code using spago
- Browser
  - Display generated HTML
  - Attach handler by client-side script (Hydration)

## Define Page type

```purs
module JellyExamples.SSG.Page where

import Data.Map as Map
import Jelly.Router.Data.Url (Url)

data Page = Top | About | NotFound

pageToUrl :: Page -> Url
pageToUrl page =
  let
    path = case page of
      Top -> []
      About -> [ "about" ]
      NotFound -> [ "404" ]
  in
    { path, hash: "", query: Map.empty }

urlToPage :: Url -> Page
urlToPage url =
  case url.path of
    [] -> Top
    [ "about" ] -> About
    _ -> NotFound

basePath :: Array String
basePath = []

```

## Define Context type

```purs
module JellyExamples.SSG.Context where

import Jelly.SSG.Data.Config (SsgContext)
import JellyExamples.SSG.Page (Page)

type Context = SsgContext Page ()

```

## Make page components

`Top`

```purs
module JellyExamples.SSG.Pages.Top where

import Prelude

import Effect.Aff (Aff)
import Jelly.Core.Components (el_, text)
import Jelly.Core.Data.Component (Component)
import JellyExamples.SSG.Context (Context)

component :: String -> Component Context
component staticData = do
  el_ "h1" do
    text $ pure "Top Page"
  el_ "p" do
    text $ pure staticData

getStaticData :: Aff String
getStaticData = pure "This is static data of the Top page."

```

`About`

```purs
module JellyExamples.SSG.Pages.About where

import Prelude

import Effect.Aff (Aff)
import Jelly.Core.Components (el_, text)
import Jelly.Core.Data.Component (Component)
import JellyExamples.SSG.Context (Context)

component :: String -> Component Context
component staticData = do
  el_ "h1" do
    text $ pure "About Page"
  el_ "p" do
    text $ pure staticData

getStaticData :: Aff String
getStaticData = pure "This is static data of the About page."

```

## Make root component

To use Jelly's SSG, you need to create a document root component.

```purs
module JellyExamples.SSG.RootComponent where

import Prelude

import Jelly.Core.Components (docTypeHTML, el_, text)
import Jelly.Core.Data.Component (Component)
import Jelly.SSG.Components (mainScript)
import Jelly.SSG.Data.Config (SsgContext)
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
    <!-- Page component will be inserted here -->
  </body>
</html>
```

## Make generator Config

```purs
module JellyExamples.SSG.Config where

import Prelude

import Jelly.SSG.Data.Config (SsgConfig)
import JellyExamples.SSG.Context (Context)
import JellyExamples.SSG.Page (Page(..), basePath, pageToUrl, urlToPage)
import JellyExamples.SSG.Pages.About as About
import JellyExamples.SSG.Pages.Top as Top
import JellyExamples.SSG.RootComponent (rootComponent)

ssgConfig :: SsgConfig Context Page
ssgConfig =
  { basePath
  , rootComponent
  , pageToUrl
  , urlToPage
  , pageComponent: case _ of
      Top -> { component: Top.component, getStaticData: Top.getStaticData }
      About -> { component: About.component, getStaticData: About.getStaticData }
      NotFound -> { component: const mempty, getStaticData: pure "" }
  , getPages: pure [ Top, About, NotFound ]
  , clientMain: "JellyExamples.SSG.ClientMain"
  , output: [ "examples", "public", "SSG" ]
  }

```

## Make client-side entry point

Next, create client-side entry points.

```purs
module JellyExamples.SSG.ClientMain where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Jelly.SSG.ClientMain (clientMain)
import JellyExamples.SSG.Config (ssgConfig)

main :: Effect Unit
main = launchAff_ $ clientMain ssgConfig

```

## Make Main module

Finally, create a Main module.

In the generator settings, specify the name of the module for the client-side entry point you just created, the output destination for index.html and index.js, and the root component.

```purs
module JellyExamples.SSG.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Jelly.SSG.Generator (generate)
import JellyExamples.SSG.Config (ssgConfig)

main :: Effect Unit
main = launchAff_ $ generate ssgConfig

```

## Run SSG

```
npx spago run --main JellyExamples.SSG.Main
```

When the Main module is executed, static files are generated.
