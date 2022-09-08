module Jelly.Data.Component where

import Prelude

import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Signal (Signal, launch, readSignal)
import Web.DOM (Element, Node)
import Web.DOM.Document (createElement)
import Web.DOM.Element (removeAttribute, setAttribute)
import Web.DOM.Element as Element
import Web.Event.Event (Event, EventType)
import Web.Event.EventTarget (addEventListener, eventListener, removeEventListener)
import Web.HTML (window)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.Window (document)

data Prop
  = PropAttribute String (Signal (Maybe String))
  | PropHandler EventType (Event -> Effect Unit)

data NodeSpec
  = NodeSpecElement
      { tagName :: String
      , props :: Array Prop
      , children :: Signal (Array ComponentInstance)
      , unmountEffect :: Effect Unit
      }
  | NodeSpecText
      { text :: Signal String
      , unmountEffect :: Effect Unit

      }

data ComponentInstance = ComponentInstance
  (Maybe { realNode :: Node, unregister :: Effect Unit })
  NodeSpec

justPropAttribute :: String -> Signal String -> Prop
justPropAttribute name = PropAttribute name <<< map Just

infix 0 PropAttribute as ?:=
infix 0 justPropAttribute as :=

on :: EventType -> (Event -> Effect Unit) -> Prop
on = PropHandler

newtype Component = Component (Effect NodeSpec)

------------
-- Render --
------------

{-
  Make Component a String for SSR and SSG.
-}

renderProp :: Prop -> Effect String
renderProp = case _ of
  PropAttribute name valueSignal -> do
    valueMaybe <- readSignal valueSignal
    case valueMaybe of
      Nothing -> pure ""
      Just value -> pure $ " " <> name <> "=\"" <> value <> "\""
  PropHandler _ _ -> pure $ ""

renderNodeSpec :: NodeSpec -> Effect String
renderNodeSpec = case _ of
  NodeSpecElement { tagName, props, children } -> do
    crn <- readSignal children
    childrenRendered <- fold <$> traverse renderComponentInstance crn

    attributesRendered <- fold <$> traverse renderProp props
    pure $ "<" <> tagName <> attributesRendered <> ">"
      <> childrenRendered
      <> "</"
      <> tagName
      <> ">"
  NodeSpecText { text } -> readSignal text

renderComponentInstance :: ComponentInstance -> Effect String
renderComponentInstance (ComponentInstance _ spec) = renderNodeSpec spec

render :: Component -> Effect String
render (Component init) = renderNodeSpec =<< init

-----------------
-- Create Node --
-----------------

{-
  Create a Node for CSR.
  Basically, it does not work with NodeJS.
-}

registerProp :: Element -> Prop -> Effect (Effect Unit)
registerProp elem = case _ of
  PropAttribute name valueSignal -> do
    launch do
      valueMaybe <- valueSignal
      liftEffect case valueMaybe of
        Nothing -> removeAttribute name elem
        Just value -> setAttribute name value elem
  PropHandler eventType handler -> do
    el <- eventListener handler
    liftEffect $ addEventListener eventType el false $ Element.toEventTarget
      elem
    pure $ removeEventListener eventType el false $ Element.toEventTarget elem

-- -- TODO: children の変更を監視する
-- createNodeFromSpec :: NodeSpec -> Effect Element
-- createNodeFromSpec { tagName, props, children } = do
--   doc <- HTMLDocument.toDocument <$> (document =<< window)
--   elem <- createElementFromSpec tagName doc
--   pure elem

-- TODO: realNode を渡す
instantiate :: Component -> Effect ComponentInstance
instantiate = case _ of
  Component init -> do
    spec <- init
    pure $ ComponentInstance Nothing spec
