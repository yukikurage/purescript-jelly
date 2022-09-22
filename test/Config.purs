module Test.Config where

import Prelude

import Jelly.SSG.Data.ClientConfig (ClientConfig)
import Jelly.SSG.Data.GeneratorConfig (GeneratorConfig)
import Record (union)
import Test.Context (Context)
import Test.Page (Page(..), basePath, pageToUrl, urlToPage)
import Test.RootComponent (hogePage, notFoundPage, rootComponent, topPage)

generatorConfig :: GeneratorConfig Context Page
generatorConfig = union clientConfig
  { pageStaticData: case _ of
      Hoge -> pure "this is hoge page data."
      Top -> pure "this is top page data."
      NotFound -> pure "this is not found page data."
  , getPages: pure [ Hoge, Top ]
  , clientMain: "Test.ClientMain"
  , output: [ "public" ]
  }

clientConfig :: ClientConfig Context Page
clientConfig =
  { basePath
  , rootComponent: rootComponent
  , pageToUrl
  , urlToPage
  , pageComponent: case _ of
      Hoge -> hogePage
      Top -> topPage
      NotFound -> notFoundPage
  }
