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
