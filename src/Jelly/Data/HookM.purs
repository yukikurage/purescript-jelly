module Jelly.Data.HookM where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, runReaderT)
import Control.Monad.Writer (class MonadTell, class MonadWriter, WriterT, runWriterT)
import Data.Tuple (Tuple)
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Web.DOM (Node)

-- | HookM はコンポーネントの初期化処理を表すモナド
-- | 基本的に Effect モナドと同様の作用をするが、コンポーネントが Unmount された時の処理も記述できる他、処理対象のノードをいつでも呼び出すことができる
-- | 前者は Writer モナドで記録され、後者は Reader モナドによって実現される
newtype HookM a = HookM
  (WriterT (Array (Effect Unit)) (ReaderT Node Effect) a)

derive newtype instance Functor HookM
derive newtype instance Apply HookM
derive newtype instance Applicative HookM
derive newtype instance Bind HookM
derive newtype instance Monad HookM
derive newtype instance MonadEffect HookM
derive newtype instance MonadAsk Node HookM
derive newtype instance MonadReader Node HookM
derive newtype instance MonadTell (Array (Effect Unit)) HookM
derive newtype instance MonadWriter (Array (Effect Unit)) HookM

runHookM :: forall a. HookM a -> Node -> Effect (Tuple a (Array (Effect Unit)))
runHookM (HookM f) node = runReaderT (runWriterT f) node
