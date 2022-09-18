module JellyExamples.Timer where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Effect.Timer (clearInterval, setInterval)
import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (makeComponent)
import Jelly.Data.Signal (modifyAtom_, signal)
import Jelly.El (text)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)

timer :: Component Unit
timer = makeComponent do
  timeSig /\ timeAtom <- signal 0

  id <- liftEffect $ setInterval 1000 $ modifyAtom_ timeAtom (_ + 1)

  useUnmountEffect $ clearInterval id

  pure $ text $ show <$> timeSig
