module JellyExamples.SSG.Context where

import Jelly.SSG.Data.Config (SsgContext)
import JellyExamples.SSG.Page (Page)

type Context = SsgContext Page ()
