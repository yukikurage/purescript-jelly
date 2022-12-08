# Jelly

Jelly is a UI framework based on Signal.

## Features

- 💥 Reactive
  State management can be done using a reactive value called a Signal. It is not FRP (Functional Reactive Programming) because it is basically a discrete value.
- 💘 No Virtual DOM
  Jelly does not use a virtual DOM. It updates the DOM directly.
- 🪜 Declarative
  With Jelly, components are defined declaratively, but it is also possible to control when components are mounted and unmounted.
- ⚙️ Hooks
  Logic can be reused and synthesized using Hooks.
- 🧱 Component
  A simple component system can be used to divide pages by role.
- 🧭 SPA Routing
  The router overrides the browser's behavior, allowing page transitions without loading the entire page.
- 📦 SSG
  Jelly can be used to generate static HTML files, and hydrate them to make them interactive.

Jelly depends [jelly-signal](https://github.com/yukikurage/purescript-jelly-signal) and [jelly-hooks](https://github.com/yukikurage/purescript-jelly-hooks)
Since systems such as component separation are provided by these, Jelly only provides HTML feature.

## Installation

```
spago install jelly
```

## Documents

See [Jelly's home page](https://jelly.yukikurage.net/) for more details.
