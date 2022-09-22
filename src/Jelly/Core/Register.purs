module Jelly.Core.Register where

import Prelude

import Control.Safely (for_)
import Data.Maybe (Maybe(..))
import Data.Traversable (for)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref (new, write)
import Jelly.Core.Data.Component (Component, runComponent)
import Jelly.Core.Data.Instance (Instance, addEventListener, firstChild, removeAttribute, setAttribute, setInnerHTML, setTextContent, updateChildren)
import Jelly.Core.Data.Prop (Prop(..))
import Jelly.Core.Data.Signal (Signal, launch)

registerChildComponent
  :: forall context. Instance -> Component context -> Record context -> Effect (Effect Unit)
registerChildComponent inst childComponent context = do
  realInstanceRef <- new =<< firstChild inst

  { instancesSig, unmountEffect } <- runComponent childComponent
    { context, realInstanceRef }

  write Nothing realInstanceRef

  stop <- launch do
    instances <- instancesSig
    liftEffect $ updateChildren instances inst

  pure do
    stop
    unmountEffect

registerProps :: Instance -> Array Prop -> Effect (Effect Unit)
registerProps inst props = do
  stops <- for props \prop -> case prop of
    PropAttribute key valueSig -> launch do
      valueMaybe <- valueSig
      liftEffect case valueMaybe of
        Just value -> setAttribute key value inst
        Nothing -> removeAttribute key inst

    PropHandler eventType listener -> addEventListener eventType listener inst

  pure $ for_ stops identity

registerText :: Instance -> Signal String -> Effect (Effect Unit)
registerText inst valueSig = do
  stop <- launch do
    value <- valueSig
    liftEffect $ setTextContent value inst

  pure stop

registerInnerHtml :: Instance -> Signal String -> Effect (Effect Unit)
registerInnerHtml inst htmlSig = do
  stop <- launch do
    html <- htmlSig
    liftEffect $ setInnerHTML html inst

  pure stop
