# Jelly

Jelly は非常に軽量な Web Application Framework です。

_Jelly is a very lightweight Web Application Framework._

仮想 DOM を用いていませんが、状態が更新された箇所のみを再描画できる仕組みを持っています。

_It does not use a virtual DOM, but has a mechanism that allows redrawing only where the state has been updated._

リアクティビティに似ていますが、とても簡単にされていて、逆に言うとそれほど抽象化はされていません。

_It is similar to reactivity, but made very simple and, conversely, not so abstract._

これは Web UI を組む際にそれほど抽象化は必要ないと判断したからです。

_This is because I decided that I don't need such abstraction when we build a Web UI._

## Installation

This package is not in package-sets, so add following to `spago.dhall`

```
...
let upstream = ...
in  upstream
  with jelly =
    { dependencies =
      [ "arrays"
      , "console"
      , "effect"
      , "foldable-traversable"
      , "maybe"
      , "prelude"
      , "refs"
      , "safely"
      , "strings"
      , "tailrec"
      , "transformers"
      , "tuples"
      , "unfoldable"
      , "web-dom"
      , "web-events"
      , "web-html"
      ]
    , repo =
        "https://github.com/yukikurage/purescript-jelly"
    , version =
        "v0.1.0"
    }
...
```

## Example

Jelly の詳細を述べる前に例を示します。非常に単純なカウンターです。

_Before going into the details of Jelly, here is an example. It is a very simple counter._

```purescript
counter :: forall r. Component r
counter = do
  count /\ modifyCounterValue <- newJelly 0

  el_ "div"
    [ el "button"
        [ on "click" \_ -> modifyCounterValue (_ + 1)
        ]
        [ text $ pure "+" ]
    , el_ "div" [ text $ show <$> count ]
    , el "button"
        [ on "click" \_ -> modifyCounterValue (_ - 1)
        ]
        [ text $ pure "-" ]
    ]
```

数字の上下のボタンでカウントを操作することができます。

_The buttons above and below the numbers can be used to control the count._

なんとなく処理内容がわかると思います。

_I think you can somewhat understand the process._

これを親コンポーネントから読み込んで、"Run" ボタンでカウンターを起動し、"Stop" ボタンでカウンターを消すようにしたいとします。これは次のように実装できます。

_Suppose we want to load this component from the parent component, and then use the "Run" button to activate the counter and the "Stop" button to turn it off. This can be implemented as follows_

```purescript
app :: forall r. Component r
app = do
  isShowCounter /\ modifyIsShowCounter <- newJelly false

  el_ "div"
    [ el "button"
        [ on "click" \_ -> modifyIsShowCounter not
        ]
        [ text $ ifM isShowCounter
            do pure "Stop"
            do pure "Run"
        ]
    , whenEl isShowCounter counter
    ]
```

`whenEl` は Jelly が提供する関数です。このように、単純なコードでコンポーネント分けまで行うことができます。

_`whenEl` is a function provided by Jelly. Thus, simple code can be used to separate components._

最後に、`runComponent` 関数に `Component` を渡して描画します。

_Finally, pass `Component` to the `runApp` function to draw it._

```purescript
main :: Effect Unit
main = runComponent unit app
```

## Jelly is under development

次の機能の追加をしていく予定です。

- グローバルな状態の管理
- Index された Props の導入

_I plan to add the following features_

- _Global State Management_
- _Indexed Props_

## Jelly Type

Component は次のように定義されています。

_Component is defined as follows_

`type Component r = Jelly r Node`

ここで `r` はグローバル状態を表していて、今は無視して結構です。

_Here `r` represents the global state, which can be ignored for now._

`Jelly r` は `MonadEffect` です。

_`Jelly r` is `MonadEffect`._

`newJelly` の型も見てみます。これは React の `useState` に対応します。

_Let's also look at the `newJelly` type. This corresponds to React's `useState`._

```purescript
newJelly :: forall m r a. MonadEffect m => Eq a => a -> m (Jelly r a /\ ((a -> a) -> Jelly r Unit))
```

返ってくるタプルは、Getter と Modifier の組です。

_The tuple returned is a pair of Getter and Modifier._

他の値の型も一気見しましょう。

_Let's take a quick look at the other value types._

```purescript
el :: forall r. String -> Array (Prop r) -> Array (Component r) -> Component r
el_ :: forall r. String -> Array (Component r) -> Component r
text :: forall r. Jelly r String -> Component r
on :: forall r. String -> (Event -> Jelly r Unit) -> Prop r
whenEl :: forall r. Jelly r Boolean -> Component r -> Component r
ifM :: forall a m. Bind m ⇒ m Boolean → m a → m a → m a
```

それぞれの役割は上の例と見比べればわかると思います。

_You can see the role of each by comparing it to the example above._

そして、 `Jelly` の動きを知るにはもう一個、関数 `launchJelly` の動きを知る必要があります。(内部でこの関数を使用しています)

_And one more thing to know how `Jelly` works: you need to know how the function `launchJelly` works. (Jelly use this function internally)_

```purescript
launchJelly :: forall r. Jelly r Unit -> Jelly r Unit
```

`Jelly a` は「いくつかの状態に依存した、a を返す副作用」を表しています。

_`Jelly a` represents "a side effect that depends on several states and returns a"._

`launchJelly` は引数に渡された `Jelly` を、初回と依存する状態が更新されるたび実行します。例を見てみます。

_`launchJelly` executes the `Jelly` passed as argument the first time and each time the dependent state is updated. Let's look at an example._

```purescript
testJelly :: forall r. Jelly r Unit
testJelly = do
  state /\ modifyState <- newJelly 0

  _ <- launchJelly do
    x <- state
    log $ show x

  modifyState (_ + 1)
  modifyState (_ + 1)
  modifyState (_ + 1)
  modifyState (_ + 1)
```

`Jelly` を `main` で実行するには `alone` 関数を使用します。

_Use the `alone` function to run `Jelly` in `main`._

```purescript
main = alone unit testJelly
```

結果 _Result_

```text
0
1
2
3
4
```

`modifyState` が呼ばれるたびに `launchJelly` に渡した `Jelly` が実行されていることがわかります。

_You can see that every time `modifyState` is called, the `Jelly` passed to `launchJelly` is executed._

このように `Jelly` は依存関係を自動で解決してくれます。これをうまく使うことで、 `el` 関数などは実装されています。

_Thus `Jelly` automatically resolves dependencies. By making good use of this, `el` functions and so on are implemented._

また、入れ子になった `launchJelly` に渡す `Jelly` の中に、また `launchJelly` があるとき、1 個めの `launchJelly` に渡した `Jelly` が更新されるたびに、2 個目の `launchJelly` は効果を失います。

_Also, if there is another `launchJelly` in the `Jelly` passed to the nested `launchJelly`, each time the `Jelly` passed to the first `launchJelly` is updated, the second `launchJelly` will lose its effect._

分かりにくいので例を示します。

_It is difficult to understand, so here is an example._

```purescript
testJelly :: forall r. Jelly r Unit
testJelly = do
  state0 /\ modifyState0 <- newJelly 0
  state1 /\ modifyState1 <- newJelly 0

  _ <- launchJelly do
    -- this is Rank 0 Jelly
    x0 <- state0
    log $ "Rank 0, state0 == " <> show x0
    _ <- launchJelly do
      -- this is Rank 1 Jelly
      x1 <- state1
      log $ "Rank 1, state0 == " <> show x0 <> ", state1 == " <> show x1
    pure unit

  log "modifyState1 (_ + 1)"
  modifyState1 (_ + 1)
  log "modifyState0 (_ + 10)"
  modifyState0 (_ + 10)
  log "modifyState1 (_ + 1)"
  modifyState1 (_ + 1)
```

結果 _Result_

```purescript
Rank 0, state0 == 0
Rank 1, state0 == 0, state1 == 0
modifyState1 (_ + 1)
Rank 1, state0 == 0, state1 == 1
modifyState0 (_ + 10)
Rank 0, state0 == 10
Rank 1, state0 == 10, state1 == 1
modifyState1 (_ + 1)
Rank 1, state0 == 10, state1 == 2
```

`modifyState0 (_ + 10)` が走り Rank 0 の `Jelly` が呼ばれると、`state0 == 0` のとき、Rank 0 の内部で呼ばれた `launchJelly` の効果は失われ、`modifyState1 (_ + 1)` をしても、`Rank 1, state0 == 0, state1 == 2` というログは残りません。

_When `modifyState0 (_ + 10)`runs and Rank 0`Jelly`is called, the effect of`launchJelly`called inside Rank 0 when`state0 == 0`is lost and`modifyState1 (_ + 1)`will not log`Rank 1, state0 == 0, state1 == 2`._

これは、親要素を更新/削除した時に子要素も更新/削除する処理に対応しています。

_This corresponds to the process of updating/deleting a child element when the parent element is updated/deleted._

ここまでの機能で、小規模な Web アプリは作れると思います。

_With the functionality up to this point, I believe it is possible to create a small-scale Web application._
