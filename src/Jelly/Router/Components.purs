module Jelly.Router.Components where

import Prelude

import Jelly.Core.Data.Component (Component, el)
import Jelly.Core.Data.Hooks (hooks)
import Jelly.Core.Data.Prop (Prop, on, (:=))
import Jelly.Router.Data.Router (RouterContext, useRouter)
import Jelly.Router.Data.Url (Url, urlToString)
import Web.Event.Event (preventDefault)
import Web.HTML.Event.EventTypes (click)

link
  :: forall context
   . Url
  -> Array Prop
  -> Component (RouterContext context)
  -> Component (RouterContext context)
link url props component = hooks do
  { pushUrl } <- useRouter
  let
    handleClick e = do
      preventDefault e
      pushUrl url

  pure $ el "a" (props <> [ on click handleClick, "href" := urlToString url ]) component

link_
  :: forall context. Url -> Component (RouterContext context) -> Component (RouterContext context)
link_ url component = link url [] component
