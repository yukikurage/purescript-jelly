module Jelly.Core.Data.Component where

import Prelude

import Control.Monad.Free (Free, foldFree, liftF)
import Control.Monad.Rec.Class (class MonadRec)
import Effect (Effect)
import Jelly.Core.Data.Prop (Prop)
import Jelly.Core.Data.Signal (Signal)

type ComponentElementSpec context =
  { tag :: String
  , props :: Array Prop
  , children :: Component context
  }

type ComponentVoidElementSpec =
  { tag :: String
  , props :: Array Prop
  }

type ComponentTextSpec = Signal String

type ComponentRawElementSpec =
  { tag :: String
  , props :: Array Prop
  , innerHtml :: Signal String
  }

type ComponentDocTypeSpec =
  { name :: String
  , publicId :: String
  , systemId :: String
  }

type ComponentSignalSpec context = Signal (Component context)

type ComponentLifeCycleSpec context =
  Record context
  -> Effect
       { onUnmount :: Effect Unit
       , component :: Component context
       }

data ComponentF context f
  = ComponentElement (ComponentElementSpec context) f
  | ComponentVoidElement ComponentVoidElementSpec f
  | ComponentText ComponentTextSpec f
  | ComponentRawElement ComponentRawElementSpec f
  | ComponentDocType ComponentDocTypeSpec f
  | ComponentSignal (ComponentSignalSpec context) f
  | ComponentLifeCycle (ComponentLifeCycleSpec context) f

newtype ComponentM context a = ComponentM (Free (ComponentF context) a)

derive newtype instance Functor (ComponentM context)
derive newtype instance Apply (ComponentM context)
derive newtype instance Applicative (ComponentM context)
derive newtype instance Bind (ComponentM context)
derive newtype instance Monad (ComponentM context)
derive newtype instance MonadRec (ComponentM context)
derive newtype instance Semigroup a => Semigroup (ComponentM context a)
derive newtype instance Monoid a => Monoid (ComponentM context a)

type Component context = ComponentM context Unit

foldComponent
  :: forall m context
   . MonadRec m
  => (ComponentF context ~> m)
  -> ComponentM context ~> m
foldComponent f (ComponentM c) = foldFree f c

el :: forall context. String -> Array Prop -> Component context -> Component context
el tag props children = ComponentM $ liftF $ ComponentElement { tag, props, children } unit

el' :: forall context. String -> Component context -> Component context
el' tag = el tag []

voidEl :: forall context. String -> Array Prop -> Component context
voidEl tag props = ComponentM $ liftF $ ComponentVoidElement { tag, props } unit

voidEl' :: forall context. String -> Component context
voidEl' tag = voidEl tag []

rawElSig :: forall context. String -> Array Prop -> Signal String -> Component context
rawElSig tag props innerHtml = ComponentM $ liftF $ ComponentRawElement { tag, props, innerHtml }
  unit

rawElSig' :: forall context. String -> Signal String -> Component context
rawElSig' tag = rawElSig tag []

rawEl :: forall context. String -> Array Prop -> String -> Component context
rawEl tag props innerHtml = rawElSig tag props (pure innerHtml)

rawEl' :: forall context. String -> String -> Component context
rawEl' tag = rawEl tag []

textSig :: forall context. Signal String -> Component context
textSig signal = ComponentM $ liftF $ ComponentText signal unit

text :: forall context. String -> Component context
text = textSig <<< pure

doctype :: forall context. String -> String -> String -> Component context
doctype name publicId systemId = ComponentM $ liftF $ ComponentDocType { name, publicId, systemId }
  unit

doctypeHtml :: forall context. Component context
doctypeHtml = doctype "html" "" ""

signalC :: forall context. Signal (Component context) -> Component context
signalC signal = ComponentM $ liftF $ ComponentSignal signal unit

ifC :: forall context. Signal Boolean -> Component context -> Component context -> Component context
ifC sig cmpTrue cmpFalse = signalC $ sig <#> \b -> if b then cmpTrue else cmpFalse

whenC :: forall context. Signal Boolean -> Component context -> Component context
whenC sig cmp = ifC sig cmp mempty

lifeCycleC
  :: forall context
   . (Record context -> Effect { onUnmount :: Effect Unit, component :: Component context })
  -> Component context
lifeCycleC effect = ComponentM $ liftF $ ComponentLifeCycle effect unit
