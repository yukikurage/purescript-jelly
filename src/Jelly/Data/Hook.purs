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

-- | anchorNode is the node after which the hook will be inserted.
type HookInternal r =
  { parentNode :: Node
  , anchorNode :: Node
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
  -> HookInternal r
  -> Effect a
runHook (Hook f) hookInternal = runReaderT f hookInternal

runHookWithCurrentContext
  :: forall r a
   . Hook r a
  -> Hook r
       { return :: a
       , childNodes :: Signal (Array Node)
       , attributes :: Array (Tuple String (Signal String))
       , deferEffect :: Effect Unit
       }
runHookWithCurrentContext hook = do
  { context } <- ask
  liftEffect $ runHook hook context
