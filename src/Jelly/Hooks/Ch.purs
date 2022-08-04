module Jelly.Hooks.Ch where

import Prelude

import Control.Monad.Reader (ask)
import Control.Safely (for_)
import Data.Array (singleton)
import Data.Maybe (Maybe, fromMaybe)
import Data.Tuple (fst, snd)
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Component (Component, runComponent)
import Jelly.Data.Hook (Hook)
import Jelly.Data.Signal (Signal, defer, signal)
import Jelly.Hooks.UseSignal (useSignal)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)
import Web.DOM (Element, Node)
import Web.DOM.Document (createTextNode)
import Web.DOM.Element (toNode)
import Web.DOM.Node (appendChild, insertBefore, removeChild)
import Web.DOM.Text as TXT
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

foreign import data UseChildComponentsState :: Type

foreign import runUnmountEffectAll :: UseChildComponentsState -> Effect Unit
foreign import newUseChildComponentsState
  :: Element -> Effect UseChildComponentsState

foreign import updateNodeChildren
  :: forall r item
   . (forall a b. a /\ b -> a)
  -> (forall a b. a /\ b -> b)
  -> (forall a. a -> Maybe a -> a)
  -> (item -> Effect (Signal item /\ (item -> Effect Unit)))
  -> (Component r -> Effect (Node /\ Effect Unit))
  -> Element
  -> UseChildComponentsState
  -> (item -> Maybe String)
  -> (Signal item -> Component r)
  -> Array item
  -> Effect Unit

-- | 子 Component を埋め込む Hook
-- | 同じキーを持つ子コンポーネントがすでにある場合、そのコンポーネントを使いまわす。
-- | それ以外の場合、Component r を使って、新しい Node を作成し、子コンポーネントとして埋め込む
-- | 削除された子コンポーネントの Unmount Effect を実行する
chsFor
  :: forall r a
   . Eq a
  => Signal (Array a)
  -> (a -> Maybe String)
  -> (Signal a -> Component r)
  -> Hook r Unit
chsFor itemsSignal itemToKey itemSignalToComponent = do
  { context, parentElement } <- ask

  let
    runComponentWithCurrentContext c = runComponent c context
    newSignal a = do
      signal /\ mod <- signal a
      pure $ signal /\ (mod <<< const)

  useChildNodeState <- liftEffect $ newUseChildComponentsState parentElement

  useSignal do
    items <- itemsSignal
    liftEffect $ updateNodeChildren
      fst
      snd
      fromMaybe
      newSignal
      runComponentWithCurrentContext
      parentElement
      useChildNodeState
      itemToKey
      itemSignalToComponent
      items

  -- | 親ノードが Unmount したとき子ノードの Unmount Effect も全部走らせる
  useUnmountEffect $ runUnmountEffectAll useChildNodeState

ch :: forall r. Component r -> Hook r Unit
ch component = chSig $ pure component

chs :: forall r. Array (Component r) -> Hook r Unit
chs components = chsSig $ pure components

-- | Signal が更新されるたび、子コンポーネントを置換する
chSig :: forall r. Signal (Component r) -> Hook r Unit
chSig componentSig = chsSig $ singleton <$> componentSig

-- | Signal が更新されるたび、子コンポーネントの配列を置換する
chsSig :: forall r. Signal (Array (Component r)) -> Hook r Unit
chsSig componentsSig = do
  { parentElement, context } <- ask

  textNode <- liftEffect $ createTextNode "" <<< toDocument =<< document =<<
    window
  let
    anchorNode = TXT.toNode textNode
    parentNode = toNode parentElement

  liftEffect $ appendChild anchorNode parentNode

  useSignal do
    components <- componentsSig
    for_ components \component -> do
      node /\ unmountEffect <- liftEffect $ runComponent component context
      liftEffect $ insertBefore node anchorNode parentNode

      defer do
        unmountEffect
        removeChild node parentNode

chWhen :: forall r. Signal Boolean -> Component r -> Hook r Unit
chWhen condSig component = chsSig do
  cond <- condSig
  pure if cond then [ component ] else []

chIf :: forall r. Signal Boolean -> Component r -> Component r -> Hook r Unit
chIf condSig componentTrue componentFalse = chSig do
  cond <- condSig
  pure if cond then componentTrue else componentFalse
