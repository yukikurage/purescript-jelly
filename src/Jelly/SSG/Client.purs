module Jelly.SSG.Client where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Jelly.Aff (awaitDocument)
import Jelly.Data.Component (Component)
import Jelly.RunJelly (runJelly)

makeClientMain :: Component () -> Effect Unit
makeClientMain component = launchAff_ do
  node <- awaitDocument
  liftEffect $ runJelly component node
