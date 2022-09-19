module JellyExamples.Hooks where

import Prelude

import Effect.Class (liftEffect)
import Effect.Console (log)
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (makeComponent)
import Jelly.El (el_, text)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

componentWithHooks :: Component ()
componentWithHooks = makeComponent do
  -- This effect runs when the component is mounted
  liftEffect $ log "Mounted"

  -- This effect runs when the component is unmounted
  useUnmountEffect $ log "Unmounted"

  pure $ el_ "h1" do
    text $ pure "Hello, World!"
