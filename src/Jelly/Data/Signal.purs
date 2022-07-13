module Jelly.Data.Signal where

import Prelude

import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Unsafe.Coerce (unsafeCoerce)

-- | Signal は動的に変化するような値を表す
-- | 内部に依存先と依存されている Signal を保存されていて、 Signal が更新したら、依存されている Signal も更新する
foreign import data Signal :: Type -> Type

-- | 型情報を忘れた Signal
-- | SignalM で使う
-- | 依存関係の解決にしか興味がない
foreign import data GenericSignal :: Type

toGenericSignal :: forall a. Signal a -> GenericSignal
toGenericSignal = unsafeCoerce

foreign import newSignalImpl
  :: forall a
   . (GenericSignal -> Effect a)
  -> (a -> a -> Boolean)
  -> Effect (Signal a)

foreign import newRefImpl
  :: forall a
   . ( (GenericSignal -> Effect a)
       -> (a -> Effect Unit)
       -> Tuple (GenericSignal -> Effect a) (a -> Effect Unit)
     )
  -> a
  -> (a -> a -> Boolean)
  -> Tuple (GenericSignal -> Effect a) (a -> Effect Unit)

foreign import readSignalImpl :: forall a. GenericSignal -> Signal a -> Effect a

foreign import readSignalAloneImpl
  :: forall a. Signal a -> Effect a

foreign import updateSignalImpl :: forall a. Signal a -> Effect Unit

foreign import disconnectSignalImpl :: forall a. Signal a -> Effect Unit

-- | SignalM モナドは Signal の値を更新するためのモナド
-- | 基本的には Effect だが、Reader モナドによりいつでも更新対象の Signal をとってくることができる
-- | したがって、動的な依存関係の自動解決が可能となっている
newtype SignalM a = SignalM (ReaderT GenericSignal Effect a)

derive newtype instance Functor SignalM
derive newtype instance Applicative SignalM
derive newtype instance Apply SignalM
derive newtype instance Bind SignalM
derive newtype instance Monad SignalM
derive newtype instance MonadAsk GenericSignal SignalM
derive newtype instance MonadReader GenericSignal SignalM
derive newtype instance MonadEffect SignalM
derive newtype instance MonadRec SignalM

runSignalM :: forall a. SignalM a -> GenericSignal -> Effect a
runSignalM (SignalM m) = runReaderT m

newSignal :: forall a. Eq a => SignalM a -> Effect (Signal a)
newSignal update = newSignalImpl (runSignalM update) eq

newSignalWithEq
  :: forall a. (a -> a -> Boolean) -> SignalM a -> Effect (Signal a)
newSignalWithEq eqFunction update = newSignalImpl (runSignalM update) eqFunction

newSignalWithoutEq :: forall a. SignalM a -> Effect (Signal a)
newSignalWithoutEq update = newSignalImpl (runSignalM update) \_ _ -> false

newRef :: forall a. Eq a => a -> Tuple (SignalM a) (a -> Effect Unit)
newRef a = newRefWithEq eq a

newRefWithEq
  :: forall a. (a -> a -> Boolean) -> a -> Tuple (SignalM a) (a -> Effect Unit)
newRefWithEq eqFunction a =
  let
    Tuple readRef writeRef = newRefImpl Tuple a eqFunction
    readRefRes = do
      genericSignal <- ask
      liftEffect $ readRef genericSignal

  in
    Tuple readRefRes writeRef

newRefWithoutEq :: forall a. a -> Tuple (SignalM a) (a -> Effect Unit)
newRefWithoutEq = newRefWithEq \_ _ -> false

readSignal :: forall a. Signal a -> SignalM a
readSignal signal = do
  genericSignal <- ask
  liftEffect $ readSignalImpl genericSignal signal

readSignalAlone :: forall a. Signal a -> Effect a
readSignalAlone = readSignalAloneImpl

updateSignal :: forall a. Signal a -> Effect Unit
updateSignal = updateSignalImpl

disconnectSignal :: forall a. Signal a -> Effect Unit
disconnectSignal = disconnectSignalImpl
