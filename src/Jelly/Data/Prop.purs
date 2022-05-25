module Jelly.Data.Props where

import Prelude

import Data.String (joinWith)
import Data.Traversable (sequence)
import Jelly.Data.Jelly (Jelly)
import Web.Event.Internal.Types (Event)

data Prop r
  = PropAttribute String (Jelly r String)
  | PropListener String (Event -> Jelly r Unit)

on :: forall r. String -> (Event -> Jelly r Unit) -> Prop r
on = PropListener

attr :: forall r. String -> Jelly r String -> Prop r
attr = PropAttribute

classes :: forall r. Array (Jelly r String) -> Prop r
classes arr = attr "class" $ joinWith " " <$> sequence arr
