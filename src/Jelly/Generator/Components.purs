module Jelly.Generator.Components where

import Prelude

import Effect.Aff (launchAff_)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (hooks)
import Jelly.Core.Data.Prop (Prop, on)
import Jelly.Generator.Data.StaticData (StaticDataContext, loadStaticData, useStaticData)
import Jelly.Router.Components (routerLink)
import Jelly.Router.Data.Router (RouterContext)
import Jelly.Router.Data.Url (Url)
import Web.UIEvent.MouseEvent.EventTypes (mouseover)

genLink
  :: forall context
   . Url
  -> Array Prop
  -> Component (RouterContext (StaticDataContext context))
  -> Component (RouterContext (StaticDataContext context))
genLink url props cmp = hooks do
  staticData <- useStaticData
  let
    handleHover _ = launchAff_ $ void $ loadStaticData staticData url.path

  pure $ routerLink url (props <> [ on mouseover handleHover ]) cmp
