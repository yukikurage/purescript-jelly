module Jelly.Component where

import Prelude

import Control.Monad.Free.Trans (FreeT, liftFreeT)
import Control.Monad.Reader (class MonadTrans, lift)
import Control.Monad.Rec.Class (class MonadRec)
import Data.Exists (Exists, mkExists, runExists)
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Jelly.Hooks (class MonadHooks)
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
  | ComponentUseHooks (ComponentUseHooksF m f)
  | ComponentUseCleaner (Effect Unit) f

derive instance Functor (ComponentF m)

newtype ComponentM m a = ComponentM (FreeT (ComponentF m) m a)

derive newtype instance Functor m => Functor (ComponentM m)
derive newtype instance Monad m => Apply (ComponentM m)
derive newtype instance Monad m => Applicative (ComponentM m)
derive newtype instance Monad m => Bind (ComponentM m)
derive newtype instance Monad m => Monad (ComponentM m)
derive newtype instance MonadRec m => MonadRec (ComponentM m)
derive newtype instance MonadEffect m => MonadEffect (ComponentM m)

instance MonadTrans ComponentM where
  lift = ComponentM <<< lift

instance MonadEffect m => MonadHooks (ComponentM m) where
  useHooks s = ComponentM $ liftFreeT $ ComponentUseHooks $ ComponentUseHooksF $ mkExists $ ComponentUseHooksE identity s
  useCleaner e = ComponentM $ liftFreeT $ ComponentUseCleaner e unit

type Component m = ComponentM m Unit

el :: forall m. Monad m => String -> Array (Prop m) -> Component m -> Component m
el tag props children = ComponentM $ liftFreeT $ ComponentEl tag props children unit

el' :: forall m. Monad m => String -> Component m -> Component m
el' tag children = ComponentM $ liftFreeT $ ComponentEl tag [] children unit

elNS :: forall m. Monad m => String -> String -> Array (Prop m) -> Component m -> Component m
elNS ns tag props children = ComponentM $ liftFreeT $ ComponentElNS ns tag props children unit

elNS' :: forall m. Monad m => String -> String -> Component m -> Component m
elNS' ns tag children = ComponentM $ liftFreeT $ ComponentElNS ns tag [] children unit

elVoid :: forall m. Monad m => String -> Array (Prop m) -> Component m
elVoid tag props = ComponentM $ liftFreeT $ ComponentElVoid tag props unit

elVoid' :: forall m. Monad m => String -> Component m
elVoid' tag = ComponentM $ liftFreeT $ ComponentElVoid tag [] unit

rawSig :: forall m. Monad m => Signal String -> Component m
rawSig sig = ComponentM $ liftFreeT $ ComponentRawSig sig unit

raw :: forall m. Monad m => String -> Component m
raw = rawSig <<< pure

textSig :: forall m. Monad m => Signal String -> Component m
textSig sig = ComponentM $ liftFreeT $ ComponentTextSig sig unit

text :: forall m. Monad m => String -> Component m
text = textSig <<< pure

doctype :: forall m. Monad m => String -> String -> String -> Component m
doctype dc publicId systemId = ComponentM $ liftFreeT $ ComponentDoctype dc publicId systemId unit

doctypeHtml :: forall m. Monad m => Component m
doctypeHtml = doctype "html" "" ""
