module Jelly.Core.Data.Component where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.Writer (class MonadTell, class MonadWriter, WriterT, runWriterT, tell)
import Data.Maybe (Maybe)
import Data.Tuple (snd)
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Effect.Ref (Ref)
import Jelly.Core.Data.Instance (Instance)
import Jelly.Core.Data.Signal (Signal)

-- | context: The context of the component.
-- | realInstanceRef: A ref to the real instance (real node), which is used to hydrate.
type ComponentInternalR context =
  { context :: Record context
  , realInstanceRef :: Ref (Maybe Instance)
  }

-- | instancesSig is a signal of instances, jelly calls updateChildren each time it changes.
-- | unmountEffect is an effect that will be called when the component is unmounted.
type ComponentInternalW =
  { instancesSig :: Signal (Array Instance)
  , unmountEffect :: Effect Unit
  }

-- | ComponentM is a monad for making instances, and unmount effects.
newtype ComponentM context a = Component
  (ReaderT (ComponentInternalR context) (WriterT ComponentInternalW Effect) a)

derive newtype instance Functor (ComponentM context)
derive newtype instance Apply (ComponentM context)
derive newtype instance Applicative (ComponentM context)
derive newtype instance Bind (ComponentM context)
derive newtype instance Monad (ComponentM context)
derive newtype instance MonadAsk (ComponentInternalR context) (ComponentM context)
derive newtype instance MonadReader (ComponentInternalR context) (ComponentM context)
derive newtype instance MonadTell ComponentInternalW (ComponentM context)
derive newtype instance MonadWriter ComponentInternalW (ComponentM context)
derive newtype instance MonadEffect (ComponentM context)
derive newtype instance Semigroup a => Semigroup (ComponentM context a)
derive newtype instance Monoid a => Monoid (ComponentM context a)
derive newtype instance MonadRec (ComponentM context)

type Component context = ComponentM context Unit

-- | Run a component.
runComponent
  :: forall context
   . Component context
  -> ComponentInternalR context
  -> Effect ComponentInternalW
runComponent (Component m) internal = do
  snd <$> runWriterT (runReaderT m internal)

-- | Add an instance to the component.
tellInstancesSig :: forall context. Signal (Array Instance) -> ComponentM context Unit
tellInstancesSig instancesSig = tell { instancesSig, unmountEffect: mempty }

-- | Add an unmount effect to the component.
tellUnmountEffect :: forall context. Effect Unit -> ComponentM context Unit
tellUnmountEffect unmountEffect = tell { instancesSig: mempty, unmountEffect }
