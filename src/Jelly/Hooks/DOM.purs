module Jelly.Hooks.DOM where

import Prelude

import Control.Monad.Reader (ask)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Effect.Ref (new, read, write)
import Jelly.Data.Emitter (addEmitterListenerOnce, emit, newEmitter, removeEmitterListener)
import Jelly.Data.HookM (HookM, runHookM)
import Jelly.Data.JellyM (JellyM, alone)
import Jelly.Data.Props (Prop(..))
import Jelly.Hooks.UseEffect (useEffect)
import Jelly.Hooks.UseUnmountEffect (useUnmountEffect)
import Web.DOM (Element, Node)
import Web.DOM.Document (createElement, createTextNode)
import Web.DOM.Element (setAttribute, toEventTarget, toNode)
import Web.DOM.Node (appendChild, insertBefore, removeChild, setTextContent)
import Web.DOM.Text as Text
import Web.Event.Event (EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.Window (document)

setProp :: forall r. Element -> Prop -> HookM r Unit
setProp element prop = case prop of
  PropAttribute name valueJelly -> do
    useEffect do
      value <- valueJelly
      liftEffect $ setAttribute name value element
      pure $ pure unit
  PropListener name listenerJelly -> do
    listener <- liftEffect $ eventListener \e -> alone $ listenerJelly e
    liftEffect $ addEventListener (EventType name) listener false $
      toEventTarget element

addChild :: forall r. Node -> JellyM (HookM r Node) -> HookM r Unit
addChild parentNode j = do
  r <- ask
  oldNodeRef <- liftEffect $ new Nothing

  -- Emitter を生成 この Emitter は parentNode が Unmount された時に呼ばれる
  parentUnmountEmitter <- liftEffect $ newEmitter
  useUnmountEffect $ liftEffect $ emit parentUnmountEmitter unit

  useEffect do
    oldNodeMaybe <- liftEffect $ read oldNodeRef
    nodeHook <- j
    newNode /\ unmount <- liftEffect $ runHookM r nodeHook

    -- parentUnmountEmitter に unmount を登録。子要素が Unmount されたら一緒に削除する
    registrationId <- liftEffect $ addEmitterListenerOnce parentUnmountEmitter
      \_ -> unmount

    liftEffect case oldNodeMaybe of
      Nothing -> do
        appendChild newNode parentNode
      Just oldNode -> do
        insertBefore newNode oldNode parentNode
        removeChild oldNode parentNode
    liftEffect $ write (Just newNode) oldNodeRef

    pure do
      liftEffect unmount
      liftEffect $ removeEmitterListener parentUnmountEmitter registrationId

el
  :: forall r
   . String
  -> Array Prop
  -> Array (JellyM (HookM r Node))
  -> HookM r Node
el tagName props children = do
  element <- liftEffect $ createElement tagName <<< toDocument =<< document =<<
    window
  for_ props $ setProp element
  for_ children $ addChild $ toNode element
  pure $ toNode element

text :: forall r. JellyM String -> HookM r Node
text strM = do
  node <- liftEffect $ Text.toNode <$>
    ( createTextNode "" <<< HTMLDocument.toDocument
        =<< document
        =<< window
    )

  useEffect do
    str <- strM
    liftEffect $ setTextContent str node
    pure $ pure unit

  pure node

-- element :: forall m. MonadEffect m => String -> Array () -> Children -> HookM m Element
-- putAt
