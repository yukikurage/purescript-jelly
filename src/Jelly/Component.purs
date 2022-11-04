module Jelly.Component where

import Prelude

import Control.Monad.Reader (ReaderT, ask, lift, runReaderT)
import Jelly.Prop (Prop, hoistProp)
import Signal (Signal)
import Signal.Hooks (class MonadHooks)

class MonadHooks m <= Component m where
  el :: String -> Array (Prop m) -> m Unit -> m Unit
  elNS :: String -> String -> Array (Prop m) -> m Unit -> m Unit
  elVoid :: String -> Array (Prop m) -> m Unit
  rawSig :: Signal String -> m Unit
  textSig :: Signal String -> m Unit
  doctype :: String -> String -> String -> m Unit

instance Component m => Component (ReaderT r m) where
  el tag props children = do
    r <- ask
    lift $ el tag (map (hoistProp \m -> runReaderT m r) props) $ runReaderT children r
  elNS ns tag props children = do
    r <- ask
    lift $ elNS ns tag (map (hoistProp \m -> runReaderT m r) props) $ runReaderT children r
  elVoid tag props = do
    r <- ask
    lift $ elVoid tag (map (hoistProp \m -> runReaderT m r) props)
  rawSig sig = lift $ rawSig sig
  textSig sig = lift $ textSig sig
  doctype dc publicId systemId = lift $ doctype dc publicId systemId

el' :: forall m. Component m => String -> m Unit -> m Unit
el' tag = el tag []

elNS' :: forall m. Component m => String -> String -> m Unit -> m Unit
elNS' namespace tag = elNS namespace tag []

elVoid' :: forall m. Component m => String -> m Unit
elVoid' tag = elVoid tag []

raw :: forall m. Component m => String -> m Unit
raw innerHtml = rawSig (pure innerHtml)

text :: forall m. Component m => String -> m Unit
text = textSig <<< pure

doctypeHtml :: forall m. Component m => m Unit
doctypeHtml = doctype "html" "" ""
