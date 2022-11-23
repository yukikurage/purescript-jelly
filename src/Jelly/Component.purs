module Jelly.Component where

import Prelude

import Control.Monad.Free (Free, foldFree, liftF)
import Control.Monad.Rec.Class (class MonadRec)
import Jelly.Prop (Prop)
import Jelly.Signal (Signal)

-- | ComponentF is a functor that represents one operations in ComponentM
data ComponentF m f
  = ComponentEl String (Array (Prop m)) (Component m) f
  | ComponentElNS String String (Array (Prop m)) (Component m) f
  | ComponentElVoid String (Array (Prop m)) f
  | ComponentRawSig (Signal String) f
  | ComponentTextSig (Signal String) f
  | ComponentDoctype String String String f
  | ComponentLifecycle (Signal (m (Component m))) f

derive instance Functor (ComponentF m)

-- | ComponentM is a monad that represents a component
newtype ComponentM m a = ComponentM (Free (ComponentF m) a)

derive newtype instance Functor m => Functor (ComponentM m)
derive newtype instance Apply (ComponentM m)
derive newtype instance Applicative (ComponentM m)
derive newtype instance Bind (ComponentM m)
derive newtype instance Monad (ComponentM m)
derive newtype instance MonadRec (ComponentM m)
derive newtype instance Semigroup a => Semigroup (ComponentM m a)
derive newtype instance Monoid a => Monoid (ComponentM m a)

-- | Usually `a` in `ComponentM m a` is `Unit`, so this is a convenient alias
type Component m = ComponentM m Unit

-- | Fold ComponentM into another monad, using foldFree.
foldComponentM :: forall m n. MonadRec n => (ComponentF m ~> n) -> ComponentM m ~> n
foldComponentM f (ComponentM c) = foldFree f c

-- | Represents a element
el :: forall m. String -> Array (Prop m) -> Component m -> Component m
el tag props children = ComponentM $ liftF $ ComponentEl tag props children unit

-- | Same as`el`, but without Props
el' :: forall m. String -> Component m -> Component m
el' tag children = ComponentM $ liftF $ ComponentEl tag [] children unit

-- | Represents a element with a namespace
elNS :: forall m. String -> String -> Array (Prop m) -> Component m -> Component m
elNS ns tag props children = ComponentM $ liftF $ ComponentElNS ns tag props children unit

-- | Same as`elNS`, but without Props
elNS' :: forall m. String -> String -> Component m -> Component m
elNS' ns tag children = ComponentM $ liftF $ ComponentElNS ns tag [] children unit

-- | Represents a void element
elVoid :: forall m. String -> Array (Prop m) -> Component m
elVoid tag props = ComponentM $ liftF $ ComponentElVoid tag props unit

-- | Same as`elVoid`, but without Props
elVoid' :: forall m. String -> Component m
elVoid' tag = ComponentM $ liftF $ ComponentElVoid tag [] unit

-- | Convert Raw HTML to a Component
rawSig :: forall m. Signal String -> Component m
rawSig sig = ComponentM $ liftF $ ComponentRawSig sig unit

-- | Same as `rawSig`, but with a constant String.
raw :: forall m. String -> Component m
raw = rawSig <<< pure

-- | Convert a text Signal to Text Node.
textSig :: forall m. Signal String -> Component m
textSig sig = ComponentM $ liftF $ ComponentTextSig sig unit

-- | Same as `textSig`, but with a constant String.
text :: forall m. String -> Component m
text = textSig <<< pure

-- | Represents a doctype node
doctype :: forall m. String -> String -> String -> Component m
doctype dc publicId systemId = ComponentM $ liftF $ ComponentDoctype dc publicId systemId unit

-- | Represents `<DOCTYPE html>`
doctypeHtml :: forall m. Component m
doctypeHtml = doctype "html" "" ""

-- | Mange component lifecycle
lifecycle :: forall m. Signal (m (Component m)) -> Component m
lifecycle sig = ComponentM $ liftF $ ComponentLifecycle sig unit

-- | Switch components based on a Signal
switch :: forall m. Monad m => Signal (Component m) -> Component m
switch sig = lifecycle $ pure <$> sig

-- | Embeds a logic into a component
hooks :: forall m. Monad m => m (Component m) -> Component m
hooks h = lifecycle $ pure h
