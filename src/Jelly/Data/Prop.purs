module Jelly.Data.Props where

import Prelude

import Jelly.Data.JellyM (JellyM)
import Web.Event.Internal.Types (Event)

data Prop
  = PropAttribute String (JellyM String)
  | PropListener String (Event -> JellyM Unit)

on :: String -> (Event -> JellyM Unit) -> Prop
on = PropListener

attr :: String -> JellyM String -> Prop
attr = PropAttribute

infix 5 attr as :=
