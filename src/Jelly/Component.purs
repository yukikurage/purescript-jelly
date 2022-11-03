module Jelly.Component where

import Prelude

import Control.Monad.Free.Trans (FreeT, hoistFreeT, liftFreeT, runFreeT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.Trans.Class (lift)
import Effect.Class (class MonadEffect)
import Jelly.Prop (Prop)
import Signal (Signal)
import Signal.Hooks (class MonadHooks, Hooks, liftHooks)

type ComponentElementSpec context =
  { tag :: String
  , props :: Array (Prop context)
  , children :: Component context
  }

type ComponentElementSpecNS context =
  { namespace :: String
  , tag :: String
  , props :: Array (Prop context)
  , children :: Component context
  }

type ComponentVoidElementSpec context =
  { tag :: String
  , props :: Array (Prop context)
  }

type ComponentTextSpec = Signal String

type ComponentRawSpec = Signal String

type ComponentDocTypeSpec =
  { name :: String
  , publicId :: String
  , systemId :: String
  }

type ComponentSignalSpec context = Signal (Component context)

data ComponentF context f
  = ComponentElement (ComponentElementSpec context) f
  | ComponentElementNS (ComponentElementSpecNS context) f
  | ComponentVoidElement (ComponentVoidElementSpec context) f
  | ComponentText ComponentTextSpec f
  | ComponentRaw ComponentRawSpec f
  | ComponentDocType ComponentDocTypeSpec f
  | ComponentSignal (ComponentSignalSpec context) f

derive instance Functor (ComponentF context)

newtype ComponentM context a = ComponentM (FreeT (ComponentF context) (Hooks context) a)

derive newtype instance Functor (ComponentM context)
derive newtype instance Apply (ComponentM context)
derive newtype instance Applicative (ComponentM context)
derive newtype instance Bind (ComponentM context)
derive newtype instance Monad (ComponentM context)
derive newtype instance MonadRec (ComponentM context)
derive newtype instance Semigroup a => Semigroup (ComponentM context a)
derive newtype instance Monoid a => Monoid (ComponentM context a)
derive newtype instance MonadEffect (ComponentM context)
instance MonadHooks context (ComponentM context) where
  liftHooks hooks = ComponentM (lift hooks)

type Component context = ComponentM context Unit

runComponentM
  :: forall context m a
   . MonadHooks context m
  => MonadRec m
  => (ComponentF context ~> m)
  -> ComponentM context a
  -> m a
runComponentM intr (ComponentM m) =
  let
    m' = hoistFreeT liftHooks m
  in
    runFreeT intr m'

el :: forall context. String -> Array (Prop context) -> Component context -> Component context
el tag props children = ComponentM $ liftFreeT $ ComponentElement { tag, props, children } unit

el' :: forall context. String -> Component context -> Component context
el' tag = el tag []

elNS
  :: forall context
   . String
  -> String
  -> Array (Prop context)
  -> Component context
  -> Component context
elNS namespace tag props children = ComponentM $ liftFreeT $ ComponentElementNS
  { namespace, tag, props, children }
  unit

elNS' :: forall context. String -> String -> Component context -> Component context
elNS' namespace tag = elNS namespace tag []

elVoid :: forall context. String -> Array (Prop context) -> Component context
elVoid tag props = ComponentM $ liftFreeT $ ComponentVoidElement { tag, props } unit

elVoid' :: forall context. String -> Component context
elVoid' tag = elVoid tag []

rawSig :: forall context. Signal String -> Component context
rawSig innerHtml = ComponentM $ liftFreeT $ ComponentRaw innerHtml unit

raw :: forall context. String -> Component context
raw innerHtml = rawSig (pure innerHtml)

textSig :: forall context. Signal String -> Component context
textSig signal = ComponentM $ liftFreeT $ ComponentText signal unit

text :: forall context. String -> Component context
text = textSig <<< pure

doctype :: forall context. String -> String -> String -> Component context
doctype name publicId systemId = ComponentM $ liftFreeT $ ComponentDocType
  { name, publicId, systemId }
  unit

doctypeHtml :: forall context. Component context
doctypeHtml = doctype "html" "" ""

signalC :: forall context. Signal (Component context) -> Component context
signalC signal = ComponentM $ liftFreeT $ ComponentSignal signal unit

ifC :: forall context. Signal Boolean -> Component context -> Component context -> Component context
ifC sig cmpTrue cmpFalse = signalC $ sig <#> \b -> if b then cmpTrue else cmpFalse

whenC :: forall context. Signal Boolean -> Component context -> Component context
whenC sig cmp = ifC sig cmp mempty
