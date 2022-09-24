module Jelly.Core.Hooks.UseContext where

import Control.Monad.Reader (ask)
import Jelly.Core.Data.Hooks (Hooks)

useContext :: forall context. Hooks context (Record context)
useContext = ask
