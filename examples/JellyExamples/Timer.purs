module JellyExamples.Timer where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Core.Components (text)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (hooks)
import Jelly.Core.Data.Signal (modifyAtom_, signal)
import Jelly.Core.Hooks.UseUnmountEffect (useUnmountEffect)

timer :: Component ()
timer = hooks do
  timeSig /\ timeAtom <- signal 0

  id <- liftEffect $ setInterval 1000 $ modifyAtom_ timeAtom (_ + 1)

  useUnmountEffect $ clearInterval id

  pure $ text $ show <$> timeSig
