module Jelly.Component where

import Prelude

import Control.Monad.Free (Free, foldFree, liftF)
import Control.Monad.Rec.Class (class MonadRec)
import Data.Exists (Exists, mkExists, runExists)
import Jelly.Prop (Prop)
import Jelly.Signal (Signal)

-- | forall a. Signal (Component m a) -> Component m (Signal a)
data ComponentUseHooksE m f a = ComponentUseHooksE (Signal a -> f) (Signal (ComponentM m a))

newtype ComponentUseHooksF m f = ComponentUseHooksF (Exists (ComponentUseHooksE m f))

instance Functor (ComponentUseHooksF m) where
  map f (ComponentUseHooksF ex) = ComponentUseHooksF $ runExists (\(ComponentUseHooksE g a) -> mkExists $ ComponentUseHooksE (f <<< g) a) ex

data ComponentF m f
  = ComponentEl String (Array (Prop m)) (Component m) f
  | ComponentElNS String String (Array (Prop m)) (Component m) f
  | ComponentElVoid String (Array (Prop m)) f
  | ComponentRawSig (Signal String) f
  | ComponentTextSig (Signal String) f
  | ComponentDoctype String String String f
  | ComponentLifecycle (Signal (m (Component m))) f

derive instance Functor (ComponentF m)

newtype ComponentM m a = ComponentM (Free (ComponentF m) a)

derive newtype instance Functor m => Functor (ComponentM m)
derive newtype instance Apply (ComponentM m)
derive newtype instance Applicative (ComponentM m)
derive newtype instance Bind (ComponentM m)
derive newtype instance Monad (ComponentM m)
derive newtype instance MonadRec m => MonadRec (ComponentM m)

type Component m = ComponentM m Unit

foldComponentM :: forall m n. MonadRec n => (ComponentF m ~> n) -> ComponentM m ~> n
foldComponentM f (ComponentM c) = foldFree f c

el :: forall m. String -> Array (Prop m) -> Component m -> Component m
el tag props children = ComponentM $ liftF $ ComponentEl tag props children unit

el' :: forall m. String -> Component m -> Component m
el' tag children = ComponentM $ liftF $ ComponentEl tag [] children unit

elNS :: forall m. String -> String -> Array (Prop m) -> Component m -> Component m
elNS ns tag props children = ComponentM $ liftF $ ComponentElNS ns tag props children unit

elNS' :: forall m. String -> String -> Component m -> Component m
elNS' ns tag children = ComponentM $ liftF $ ComponentElNS ns tag [] children unit

elVoid :: forall m. String -> Array (Prop m) -> Component m
elVoid tag props = ComponentM $ liftF $ ComponentElVoid tag props unit

elVoid' :: forall m. String -> Component m
elVoid' tag = ComponentM $ liftF $ ComponentElVoid tag [] unit

rawSig :: forall m. Signal String -> Component m
rawSig sig = ComponentM $ liftF $ ComponentRawSig sig unit

raw :: forall m. String -> Component m
raw = rawSig <<< pure

textSig :: forall m. Signal String -> Component m
textSig sig = ComponentM $ liftF $ ComponentTextSig sig unit

text :: forall m. String -> Component m
text = textSig <<< pure

doctype :: forall m. String -> String -> String -> Component m
doctype dc publicId systemId = ComponentM $ liftF $ ComponentDoctype dc publicId systemId unit

doctypeHtml :: forall m. Component m
doctypeHtml = doctype "html" "" ""

lifecycle :: forall m. Signal (m (Component m)) -> Component m
lifecycle sig = ComponentM $ liftF $ ComponentLifecycle sig unit

switch :: forall m. Monad m => Signal (Component m) -> Component m
switch sig = lifecycle $ pure <$> sig

hooks :: forall m. Monad m => m (Component m) -> Component m
hooks h = lifecycle $ pure h