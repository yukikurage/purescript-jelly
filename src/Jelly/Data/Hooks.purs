module Jelly.Data.Hooks where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Effect.Ref (Ref, new, read)
import Jelly.Data.Jelly as J
import Web.DOM (Node)

type HooksInternal r =
  { context :: r
  , unmountEffectRef :: Ref (Effect Unit)
  , nodesJellyRef :: Ref (J.Jelly (Array Node))
  }

newtype Hooks r a = Hooks (ReaderT (HooksInternal r) Effect a)

derive newtype instance Functor (Hooks r)
derive newtype instance Apply (Hooks r)
derive newtype instance Applicative (Hooks r)
derive newtype instance Bind (Hooks r)
derive newtype instance Monad (Hooks r)
derive newtype instance MonadEffect (Hooks r)
derive newtype instance MonadAsk (HooksInternal r) (Hooks r)
derive newtype instance MonadRec (Hooks r)

runHooks
  :: forall r a
   . r
  -> Hooks r a
  -> Effect
       { result :: a
       , unmountEffect :: Effect Unit
       , nodesJelly :: J.Jelly (Array Node)
       }
runHooks context (Hooks h) = do
  unmountEffectRef <- new $ pure unit
  nodesJellyRef <- new <<< J.read =<< J.new []

  result <- runReaderT h
    { context
    , unmountEffectRef
    , nodesJellyRef
    }

  unmountEffect <- read unmountEffectRef
  nodesJelly <- read nodesJellyRef
  pure $
    { result
    , unmountEffect
    , nodesJelly
    }
