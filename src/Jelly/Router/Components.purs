module Jelly.Router.Components where

import Prelude

import Jelly (type (+), Component, Prop, hooks, on, (:=))
import Jelly.Element as JE
import Jelly.Router.Data.Router (RouterContext, useRouter)
import Jelly.Router.Data.Url (Url, urlToString)
import Web.Event.Event (preventDefault)
import Web.HTML.Event.EventTypes (click)

routerLink
  :: forall context
   . Url
  -> Array Prop
  -> Component (RouterContext + context)
  -> Component (RouterContext + context)
routerLink url props component = hooks do
  { pushUrl, basePath } <- useRouter
  let
    handleClick e = do
      preventDefault e
      pushUrl url

  pure $ JE.a ([ on click handleClick, "href" := urlToString basePath url ] <> props) component

routerLink'
  :: forall context
   . Url
  -> Component (RouterContext + context)
  -> Component (RouterContext + context)
routerLink' url component = routerLink url [] component
