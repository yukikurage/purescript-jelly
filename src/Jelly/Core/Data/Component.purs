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

type ComponentTextSpec = Signal String

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
  | ComponentText ComponentTextSpec f
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

el_ :: forall context. String -> Component context -> Component context
el_ tag children = el tag [] children

text :: forall context. Signal String -> Component context
text signal = ComponentM $ liftF $ ComponentText signal unit

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
