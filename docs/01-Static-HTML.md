# 01 Static HTML

## `el`, `el_`, and `text`

`el` and `el_` are functions that create HTML elements.

`el` can take props, whereas `el_` cannot.

```purs
component = el "h1" [ "class" := "title" ] do
  text $ pure "Hello, Jelly!"
```

↓

```html
<h1 class="title">Hello, Jelly!</h1>
```

Component is a monad and multiple child elements can be added by writing.

```purs
component = el "div" do
  el_ "h1" do
    text $ pure "Hello, Jelly!"
  el_ "p" do
    text $ pure "This is a Jelly example."
    el_ "div" do
      text $ pure "This is a nested element."
```

## `text`

`text` is a function that creates text nodes.

## Props

Props represent attributes and event handlers.

In Jelly, you can define attributes using the `:=` operator and handlers using the `on` function.

```purs
component = el "button" [ "class" := "btn", on "click" \_ -> log "Clicked!" ] do
  text $ pure "Click Me!"
```
