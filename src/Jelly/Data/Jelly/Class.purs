module Jelly.Data.Jelly.Class where

import Prelude

import Jelly.Data.Jelly (Jelly)

class Monad m <= MonadJelly m where
  liftJelly :: forall a. Jelly a -> m a
