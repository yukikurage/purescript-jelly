module Jelly.SSG.Hooks where

import Prelude

import Effect.Aff (Aff)
import Jelly.Core.Data.Hooks (Hooks)
import Jelly.Router.Data.Router (useRouter)
import Jelly.SSG.Data.Context (SsgContext)
import Jelly.SSG.Data.StaticData (dataPath, pokeStaticData, useStaticData)

usePrefetch :: forall page context. page -> Hooks (SsgContext page context) (Aff String)
usePrefetch page = do
  { pageToUrl, basePath } <- useRouter
  staticData <- useStaticData

  pure $ pokeStaticData staticData $ dataPath basePath $ pageToUrl
    page
