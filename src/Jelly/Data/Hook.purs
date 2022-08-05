module Jelly.Data.Hook where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.ST.Global (Global, toEffect)
import Control.Safely (for_)
import Data.Array (fold)
import Data.Array.ST (STArray)
import Data.Array.ST as AST
import Data.Traversable (sequence)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Foreign.Object as FO
import Foreign.Object.ST (STObject)
import Foreign.Object.ST as FOST
import Jelly.Data.Signal (Signal, launch)
import Web.DOM (Element)
import Web.DOM.Element (setAttribute)

type HookInternal r =
  { parentElement :: Element
  , unmountEffectsRef :: STArray Global (Effect Unit)
  , propsRef :: STObject Global (Array (Signal String))
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
  unmountEffectsRef <- toEffect $ AST.new
  propsRef <- toEffect $ FOST.new

  return <- runReaderT f
    { parentElement, unmountEffectsRef, propsRef, context }

  (props :: Array _) <- FO.toUnfoldable <$> toEffect (FO.freezeST propsRef)
  for_ props \(key /\ value) -> do
    let
      vSig = fold <$> sequence value
    stop <- launch do
      v <- vSig
      liftEffect $ setAttribute key v parentElement
    _ <- toEffect $ AST.push stop unmountEffectsRef
    pure unit

  unmountEffects <- toEffect $ AST.freeze unmountEffectsRef
  let
    unmountEffect = for_ unmountEffects identity

  pure $ return /\ unmountEffect
