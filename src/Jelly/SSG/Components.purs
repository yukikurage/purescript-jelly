module Jelly.SSG.Components where

import Prelude

import Effect.Aff (launchAff_)
import Jelly.Core.Components (el)
import Jelly.Core.Data.Component (Component)
import Jelly.Core.Data.Hooks (hooks)
import Jelly.Core.Data.Prop (Prop, on, (:=))
import Jelly.Router.Data.Router (useRouter)
import Jelly.Router.Data.Url (makeAbsoluteFilePath, urlToString)
import Jelly.SSG.Data.Context (SsgContext)
import Jelly.SSG.Hooks (usePrefetch)
import Web.Event.Event (preventDefault)
import Web.UIEvent.MouseEvent.EventTypes (click, mouseenter)

mainScript :: forall page context. Component (SsgContext page context)
mainScript = hooks do
  { basePath } <- useRouter
  pure $ el "script"
    [ "defer" := true
    , "type" := "text/javascript"
    , "src" := makeAbsoluteFilePath (basePath <> [ "index.js" ])
    ]
    mempty

link
  :: forall page context
   . page
  -> Array Prop
  -> Component (SsgContext page context)
  -> Component (SsgContext page context)
link page props component = hooks do
  { pageToUrl, basePath, pushPage } <- useRouter

  prefetch <- usePrefetch page
  let
    handleHover _ = launchAff_ $ void $ prefetch
    handleClick e = do
      preventDefault e
      pushPage page

  pure $ el "a"
    ( [ "href" := urlToString basePath (pageToUrl page)
      , on mouseenter handleHover
      , on click handleClick
      ] <> props
    )
    component

link_
  :: forall page context
   . page
  -> Component (SsgContext page context)
  -> Component (SsgContext page context)
link_ page component = link page mempty component
