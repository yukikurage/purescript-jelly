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
    JC.text $ show count 

-- | Jelly 側が用意する関数
-- | コンポーネントからのイベントで状態を変更する
feedback :: forall a ev. (a -> Component ev) -> (ev -> a -> a) -> a -> Component ev

-- | こうやってつかう
incrementButton = feedback buttonAndText (\_ i -> i + 1) 0

-- | コンポーネントのイベントをすべて無視する
-- | これによって他のコンポーネントに子コンポーネントとして埋め込むことができる
ignore :: forall a ev. Component ev -> Component a
```

副作用は？ たとえばボタンを押すごとに現在の `count` を `log` に残したいとき
このままだと差分検出のショートカットもできない

