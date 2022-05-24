module Jelly.Data.Props where

import Prelude

import Jelly.Data.Jelly (Jelly)
import Web.Event.Internal.Types (Event)

data Prop
  = PropAttribute String (Jelly String)
  | PropListener String (Event -> Jelly Unit)

on :: String -> (Event -> Jelly Unit) -> Prop
on = PropListener

attr :: String -> Jelly String -> Prop
attr = PropAttribute

infix 5 attr as :=
