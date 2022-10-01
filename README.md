# Jelly

Jelly is a framework with the following features

- No virtual DOM
- Declarative
- State management by reactivity (not FRP)
- Logic synthesis and reuse via Hooks
- Simple component separation
- SSG & SPA Routing support

## About Signal

The Signal system is similar to [purescript-signal](https://github.com/bodil/purescript-signal) with the following differences.

- No functions for merging or filtering
- It is a monad
- Can stop an Effect Signal from running

In other words, it is a monad instead of a reduced flexibility.

## Installation

```
spago install jelly
```

## Documents

See [Jelly's home page](https://jelly.yukikurage.net/) for more details.
