module Jelly.Data.Hook
  ( Hook
  , runHook
  , useContext
  , useModifyProp
  , useRef
  , useUnmountEffect
  ) where

import Prelude

import Control.Monad.Reader (ReaderT(..), runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Monad.ST.Global (Global, toEffect)
import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Foreign.Object as FO
import Foreign.Object.ST (STObject)
import Foreign.Object.ST as FOST
import Jelly.Data.Signal (Signal, launch)
import Web.DOM (Element)
import Web.DOM.Element (setAttribute)

type HookInternal r =
  { parentElement :: Element
  , unmountEffectRef :: Ref (Effect Unit)
  , propsRef :: STObject Global (Signal String)
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
derive newtype instance MonadRec (Hook r)

useInternalAsk :: forall r. Hook r (HookInternal r)
useInternalAsk = Hook $ ReaderT pure

useContext :: forall r. Hook r r
useContext = (\r -> r.context) <$> useInternalAsk

useUnmountEffect :: forall r. Effect Unit -> Hook r Unit
useUnmountEffect unmountEffect = do
  { unmountEffectRef } <- useInternalAsk
  liftEffect $ Ref.modify_ (_ *> unmountEffect) unmountEffectRef

useRef :: forall r. Hook r Element
useRef = do
  { parentElement } <- useInternalAsk
  pure parentElement

useModifyProp
  :: forall r
   . String
  -> (Signal String -> Signal String)
  -> Hook r Unit
useModifyProp key f = do
  { propsRef } <- useInternalAsk
  currentMaybe <- liftEffect $ toEffect $ FOST.peek key propsRef
  let
    newProp = case currentMaybe of
      Nothing -> f $ pure ""
      Just current -> f current
  _ <- liftEffect $ toEffect $ FOST.poke key newProp propsRef
  pure unit

runHook
  :: forall r
   . Hook r Unit
  -> r
  -> Element
  -> Effect (Effect Unit)
runHook (Hook f) context parentElement = do
  unmountEffectRef <- Ref.new $ pure unit
  propsRef <- toEffect $ FOST.new

  runReaderT f
    { parentElement, unmountEffectRef, propsRef, context }

  -- Register Props
  (props :: Array _) <- FO.toUnfoldable <$> toEffect (FO.freezeST propsRef)
  for_ props \(key /\ value) -> do
    stop <- launch do
      v <- value
      liftEffect $ setAttribute key v parentElement
    Ref.modify_ (_ *> stop) unmountEffectRef

  unmountEffect <- Ref.read unmountEffectRef
  pure $ unmountEffect
