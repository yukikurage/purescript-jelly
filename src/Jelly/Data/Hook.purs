module Jelly.Data.Hook where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.ST.Global (Global, toEffect)
import Control.Safely (for_)
import Data.Array.ST (STArray, freeze, new)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Web.DOM (Element)

type HookInternal r =
  { parentElement :: Element
  , unmountEffectsRef :: STArray Global (Effect Unit)
  , context :: r
  }

-- | Hook はコンポーネントの初期化処理を表すモナド
newtype Hook r a = Hook (ReaderT (HookInternal r) Effect a)

derive newtype instance Functor (Hook r)
derive newtype instance Apply (Hook r)
derive newtype instance Applicative (Hook r)
derive newtype instance Bind (Hook r)
derive newtype instance Monad (Hook r)
derive newtype instance MonadEffect (Hook r)
derive newtype instance MonadAsk (HookInternal r) (Hook r)
derive newtype instance MonadReader (HookInternal r) (Hook r)
derive newtype instance MonadRec (Hook r)

runHook
  :: forall r a
   . Hook r a
  -> r
  -> Element
  -> Effect (a /\ Effect Unit)
runHook (Hook f) context parentElement = do
  unmountEffectsRef <- toEffect $ new

  return <- runReaderT f
    { parentElement, unmountEffectsRef, context }
  unmountEffects <- toEffect $ freeze unmountEffectsRef
  let
    unmountEffect = for_ unmountEffects identity

  pure $ return /\ unmountEffect
