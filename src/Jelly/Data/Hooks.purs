module Jelly.Data.Hooks where

import Prelude

{-
見た目

hook = do
  hogeSig /\ hogeAtom <- signal "hoge"

  pure $ el "div" [
    "class" := hogeSig
  ] [
    el "div" [] [text hogeSig]
  ]
-}
