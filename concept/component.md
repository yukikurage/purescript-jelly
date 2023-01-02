## 目標

- 宣言的なコンポーネントの定義
- Hooks パターンのようなロジックの使いまわし → FRP ？
- 差分の直接検出によるパフォーマンス向上 → Signal

## Types
- `Component ev` .. `ev` 型の `Event` を発行するコンポーネント

```purescript
-- | ボタンを押したとき Unit 型のイベントを発行するコンポーネント
buttonAndCount :: Int -> Component Unit
buttonAndCount count = JC.do
  JC.div [on click unit] JC.do
    JC.text "Click me"
  JC.text $ show count

-- | Jelly 側が用意する関数
-- | コンポーネントからのイベントで状態を変更する
feedback :: forall a ev. (a -> Component ev) -> (ev -> a -> a) -> a -> Component ev

-- | こうやってつかう
incrementButton :: Component Unit
incrementButton = feedback buttonAndText (\_ i -> i + 1) 0

-- | コンポーネントのイベントをすべて無視する
-- | これによって他のコンポーネントに子コンポーネントとして埋め込むことができる
ignore :: forall a ev. Component ev -> Component a
```

副作用は？ たとえばボタンを押すごとに現在の `count` を `log` に残したいとき
このままだと差分検出のショートカットもできない

→ とりあえず FRP を導入してみる

```purescript
buttonAndCount :: Signal Int -> Component Unit
buttonAndCount count = JC.do
  JC.div [on click unit] JC.do
    JC.text "Click me"
  JC.textSig $ show <$> count

feedback :: forall ev. (Event ev -> Component ev) -> Component ev
runEffect :: Event (Effect Unit) -> Effect Unit
embedComponent :: Node -> Component Void -> Event (Effect Unit)
ignore :: forall a ev. Component ev -> Component a
reduce :: forall a ev. Event ev -> a -> (ev -> a -> a) -> Signal a

counter :: Component Unit
counter = ignore $ feedback \ev ->
  let
    count = reduce ev 0 \_ i -> i + 1
  in
    JC.do
      JC.div [on click unit] JC.do
        JC.text "Click me"
      JC.textSig $ show <$> count

useEvent :: forall ev. ((Event ev /\ Register ev) -> Component) -> Component
useEffect :: forall ev. Event (Effect Unit) -> (Unit -> Component) -> Component

counter :: Component 
counter = useEvent \(incrEv /\ incrReg) -> 
  let
    count = reduce incrEv 0 \_ i -> i + 1
  in
    JC.do
      JC.div [on click incrReg] JC.do
        JC.text "Click me"
      JC.textSig $ show <$> count

-- | Signal から値を取り出す　最初に必ず発火する
pick :: forall a. Signal a -> Event a
-- | Signal の値の変化を検出する　最初に必ず発火する
react :: forall a. Signal a -> Event { prev :: Mayve a, next :: Mayve a }
sample :: forall a b. Signal a -> Event b -> Event (Tuple a b)

counter :: Component
counter = Hooks.do
  incrEv /\ incrReg <- useEvent
  let
    count = reduce incrEv 0 $ const (_ + 1)
  useEffect $ react count <#> logShow
  JC.do
    JC.div [on click incrReg] JC.do
      JC.text "Click me"
    JC.textSig $ show <$> count
```