module Jelly.Data.Props where

import Jelly.Data.JellyM (JellyM)
import Web.Event.Internal.Types (Event)

data Prop m
  = PropAttribute String (JellyM m String)
  | PropListener String (Event -> JellyM m String)

-- setProps :: Element -> Array Prop -> m Unit
-- setProps
