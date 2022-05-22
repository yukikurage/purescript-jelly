module Jelly.Data.Modifier where

import Prelude

import Jelly.Data.JellyM (JellyM)

type Modifier m a = (a -> a) -> JellyM m Unit
