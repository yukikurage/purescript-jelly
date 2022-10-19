module Jelly.Router.Components where

import Prelude

import Jelly.Data.Component (Component)
import Jelly.Data.Hooks (hooks)
import Jelly.Data.Prop (Prop, on, (:=))
import Jelly.Element as JE
import Jelly.Router.Data.Router (class RouterContext, useRouter)
import Jelly.Router.Data.Url (Url, urlToString)
import Web.Event.Event (preventDefault)
import Web.HTML.Event.EventTypes (click)

routerLink
  :: forall context
   . RouterContext context
  => Url
  -> Array Prop
  -> Component context
  -> Component context
routerLink url props component = hooks do
  { pushUrl, basePath } <- useRouter
  let
    handleClick e = do
      preventDefault e
      pushUrl url

  pure $ JE.a ([ on click handleClick, "href" := urlToString basePath url ] <> props) component

routerLink'
  :: forall context
   . RouterContext context
  => Url
  -> Component context
  -> Component context
routerLink' url component = routerLink url [] component
