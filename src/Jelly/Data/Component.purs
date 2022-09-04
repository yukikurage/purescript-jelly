module Jelly.Data.Component where

import Prelude

import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Class (liftEffect)
import Jelly.Data.Signal (Signal, launch, readSignal)
import Web.DOM (Element)
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

type ElementSpec =
  { tagName :: String
  , props :: Array Prop
  , children :: Signal (Array ComponentInstance)
  , unmountEffect :: Effect Unit
  }

data ComponentInstance
  = ComponentInstanceElement
      (Maybe { realElement :: Element, unregister :: Effect Unit })
      ElementSpec
  | ComponentInstanceText String

justPropAttribute :: String -> Signal String -> Prop
justPropAttribute name = PropAttribute name <<< map Just

infix 0 PropAttribute as ?:=
infix 0 justPropAttribute as :=

on :: EventType -> (Event -> Effect Unit) -> Prop
on = PropHandler

data Component
  = ComponentElement (Effect ElementSpec)
  | ComponentText String

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

renderElementSpec :: ElementSpec -> Effect String
renderElementSpec { tagName, props, children } = do
  crn <- readSignal children
  childrenRendered <- fold <$> traverse renderComponentInstance crn

  attributesRendered <- fold <$> traverse renderProp props
  pure $ "<" <> tagName <> attributesRendered <> ">"
    <> childrenRendered
    <> "</"
    <> tagName
    <> ">"

renderComponentInstance :: ComponentInstance -> Effect String
renderComponentInstance = case _ of
  ComponentInstanceElement _ spec -> renderElementSpec spec
  ComponentInstanceText text -> pure text

render :: Component -> Effect String
render component = case component of
  ComponentElement init -> renderElementSpec =<< init
  ComponentText signal -> pure $ signal

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

-- TODO: children の変更を監視する
createElementFromSpec :: ElementSpec -> Effect Element
createElementFromSpec { tagName, props, children } = do
  doc <- HTMLDocument.toDocument <$> (document =<< window)
  elem <- createElement tagName doc
  pure elem

-- TODO: realElement を渡す
instantiate :: Component -> Effect ComponentInstance
instantiate = case _ of
  ComponentElement init -> do
    spec <- init
    pure $ ComponentInstanceElement Nothing spec
  ComponentText text -> pure $ ComponentInstanceText text
