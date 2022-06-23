module Jelly.Data.Props where

import Prelude

import Data.String (joinWith)
import Data.Traversable (sequence)
import Jelly.Data.Jelly (Jelly)
import Web.Event.Internal.Types (Event)

data Prop
  = PropAttribute String (Jelly String)
  | PropListener String (Event -> Jelly Unit)

-- | Make Listener Prop. ex) on "click" \ev -> ...
on :: String -> (Event -> Jelly Unit) -> Prop
on = PropListener

-- | Make Attribute Prop. ex) attr "id" $ pure "hoge-id"
attr :: String -> Jelly String -> Prop
attr = PropAttribute

infix 5 attr as @=

-- | Make class attribute from Array.
classes :: Array (Jelly String) -> Prop
classes arr = attr "class" $ joinWith " " <$> sequence arr
