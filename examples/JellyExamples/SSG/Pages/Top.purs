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
