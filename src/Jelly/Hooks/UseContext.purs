module Jelly.Hooks.UseContext where

import Prelude

import Control.Monad.Reader (ask)
import Jelly.Data.Hooks (Hooks)

useContext :: forall context. Hooks context context
useContext = (_.context) <$> ask
