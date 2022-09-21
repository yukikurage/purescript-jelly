module Test.Config where

import Prelude

import Jelly.SSG.Data.Config (SsgConfig)
import Test.Context (Context)
import Test.Page (Page(..), basePath, pageToUrl, urlToPage)
import Test.RootComponent (hogePage, notFoundPage, rootComponent, topPage)

config :: SsgConfig Context Page
config =
  { basePath
  , rootComponent: rootComponent
  , pageToUrl
  , urlToPage
  , pageComponent: case _ of
      Hoge ->
        { component: hogePage
        , getStaticData: pure "this is hoge page data."
        }
      Top ->
        { component: topPage
        , getStaticData: pure "this is top page data."
        }
      NotFound ->
        { component: notFoundPage
        , getStaticData: pure "this is not found page data."
        }
  , getPages: pure [ Hoge, Top ]
  , clientMain: "Test.ClientMain"
  , output: "public"
  }
