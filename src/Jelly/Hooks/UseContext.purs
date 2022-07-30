module Jelly.Hooks.UseContext where

import Prelude

import Control.Monad.Reader (ask)
import Jelly.Data.Hook (Hook)

useContext :: forall r. Hook r r
useContext = (\r -> r.context) <$> ask
