module Jelly.Data.Props where

import Prelude

import Data.String (joinWith)
import Data.Traversable (sequence)
import Jelly.Data.Jelly (Jelly)
import Web.Event.Internal.Types (Event)

data Prop r
  = PropAttribute String (Jelly r String)
  | PropListener String (Event -> Jelly r Unit)

-- | Make Listener Prop. ex) on "click" \ev -> ...
on :: forall r. String -> (Event -> Jelly r Unit) -> Prop r
on = PropListener

-- | Make Attribute Prop. ex) attr "id" $ pure "hoge-id"
attr :: forall r. String -> Jelly r String -> Prop r
attr = PropAttribute

-- | Make class attribute from Array.
classes :: forall r. Array (Jelly r String) -> Prop r
classes arr = attr "class" $ joinWith " " <$> sequence arr
