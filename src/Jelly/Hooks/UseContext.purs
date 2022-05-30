module Jelly.Hooks.UseContext where

import Prelude

import Control.Monad.Reader (ask)
import Jelly.Data.Hooks (Hooks)

useContext :: forall r. Hooks r r
useContext = _.contexts <$> ask
