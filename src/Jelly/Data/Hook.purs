module Jelly.Data.Hook where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.ST.Global (Global, toEffect)
import Control.Safely (for_)
import Data.Array.ST (STArray, freeze, new)
import Data.Traversable (sequence)
import Data.Tuple (Tuple)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Jelly.Data.Signal (Signal)
import Web.DOM (Node)
import Web.Event.Internal.Types (Event)

type HookInternal r =
  { childNodesRef :: STArray Global (Signal (Array Node))
  , propsRef :: STArray Global (Tuple String (Signal String))
  , handlersRef :: STArray Global (Tuple String (Event -> Signal String))
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
  -> Effect
       { return :: a
       , childNodes :: Signal (Array Node)
       , props :: Array (Tuple String (Signal String))
       , handlers :: Array (Tuple String (Event -> Signal String))
       , unmountEffect :: Effect Unit
       }
runHook (Hook f) context = do
  childNodesRef <- toEffect $ new
  propsRef <- toEffect $ new
  handlersRef <- toEffect $ new
  unmountEffectsRef <- toEffect $ new
  return <- runReaderT f
    { childNodesRef, propsRef, handlersRef, unmountEffectsRef, context }
  childNodesArr <- toEffect $ freeze childNodesRef
  props <- toEffect $ freeze propsRef
  handlers <- toEffect $ freeze handlersRef
  unmountEffects <- toEffect $ freeze unmountEffectsRef
  let
    childNodes = join <$> sequence childNodesArr
    unmountEffect = for_ unmountEffects identity
  pure { return, childNodes, unmountEffect, props, handlers }

runHookWithCurrentContext
  :: forall r a
   . Hook r a
  -> Hook r
       { return :: a
       , childNodes :: Signal (Array Node)
       , props :: Array (Tuple String (Signal String))
       , handlers :: Array (Tuple String (Event -> Signal String))
       , unmountEffect :: Effect Unit
       }
runHookWithCurrentContext hook = do
  { context } <- ask
  liftEffect $ runHook hook context
