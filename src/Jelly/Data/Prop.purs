module Jelly.Data.Props where

import Prelude

import Data.String (joinWith)
import Data.Traversable (sequence)
import Jelly.Data.Jelly (Jelly)
import Web.Event.Internal.Types (Event)

data Prop
  = PropAttribute String (Jelly String)
  | PropListener String (Event -> Jelly Unit)

on :: String -> (Event -> Jelly Unit) -> Prop
on = PropListener

attr :: String -> Jelly String -> Prop
attr = PropAttribute

classes :: Array (Jelly String) -> Prop
classes arr = attr "class" $ joinWith " " <$> sequence arr
