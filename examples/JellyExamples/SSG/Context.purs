module JellyExamples.SSG.Context where

import Jelly.SSG.Data.GeneratorConfig (SsgContext)
import JellyExamples.SSG.Page (Page)

type Context = SsgContext Page ()
