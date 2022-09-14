module Test.Html where

import Prelude

import Jelly.Data.Component (Component)
import Jelly.Data.Prop ((:=))
import Jelly.El (el, el_)
import Test.Context (Context)

-- <html>
--     <head>
--         <script async="" type="text/javascript" src="./index.js"></script>
--     </head>
--     <body>
--         <div id="root"></div>
--     </body>
-- </html>

html :: Component Context -> Component Context
html component = el_ "html" do
  el_ "head" do
    el "script" [ "async" := pure "", "type" := pure "text/javascript", "src" := pure "./index.js" ]
      mempty
  el_ "body" do
    el "div" [ "id" := pure "root" ] component
