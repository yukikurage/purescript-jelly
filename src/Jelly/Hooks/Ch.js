export const newUseChildComponentsState = (parentElement) => () => {
  // anchorNode は始めのノードを示す。
  // 便宜上空のText Node
  // もっといいやり方が合ったら変える
  const anchorNode = window.document.createTextNode("");

  parentElement.appendChild(anchorNode);

  return {
    anchorNode,
    keyToNodeModMap: new Map(), // key から Node, Sig, Mod へのマップ。
    nodeToUnmountEffectMap: new Map(), // Node から Unmount 関数へのマップ
  };
};

export const runUnmountEffectAll = (useChildComponentsState) => () =>
  useChildComponentsState.nodeToUnmountEffectMap.forEach((unmountEffect) =>
    unmountEffect()
  );

export const updateNodeChildren =
  (fst /* a /\ b -> a */) =>
  (snd /* a /\ b -> b */) =>
  (fromMaybe /* a -> Maybe a -> a */) =>
  (newSignal /* item -> Effect (Signal /\ (item -> Effect Unit)) */) =>
  (
    runComponent /* runComponent :: Component r -> Effect (Node /\ Effect Unit) */
  ) =>
  (parentElement /* Element */) =>
  (useChildComponentsState) =>
  (itemToKey /* item -> Maybe String */) =>
  (itemSigToComponent /* Signal item -> Component r */) =>
  (items /* Array item */) =>
  () => {
    const { anchorNode, keyToNodeModMap, nodeToUnmountEffectMap } =
      useChildComponentsState;

    const newKeyToNodeModMap = new Map();

    const willUnmountNodes = new Set(nodeToUnmountEffectMap.keys()); // 最終的に Unmount される Node の一覧。適宜削除する

    let itr = anchorNode.nextSibling;

    items.map((item) => {
      // item を key に変換
      const maybeKey = itemToKey(item);
      const key = fromMaybe(undefined)(maybeKey); //: undefined | string

      // 以下 Node を対応する Node と Mod (Signal に 値を適用する関数)を取得する処理
      let node;
      let mod;

      if (key !== undefined && keyToNodeMap.has(key)) {
        // key が存在する場合は、既存の Node を使いまわす
        const nodeMod = keyToNodeModMap.get(key); // {node, mod} を取得

        node = nodeMod.node
        mod = nodeMod.mod;

        willUnmountNodes.delete(node); // Node が Unmount されないようにする

        newKeyToNodeModMap.set(key, node); // key と node のマップに追加
      } else {
        // それ以外の場合、新しい Node を作成する。

        const sig_mod = newSignal(item)(); // 新しい Signal と Mod の組を作成
        const sig = fst(sig_mod); // Signal は Component に渡す時にしか使わない
        mod = snd(sig_mod); // Mod は 外の let で宣言したものに代入しておく

        const component = itemSigToComponent(sig); // Signal から Component を作成

        const node_unmountEffect = runComponent(component)(); // Component の初期化処理を走らせて node と unmountEffect を取得
        node = fst(node_unmountEffect); // let で宣言した node に代入
        const unmountEffect = snd(node_unmountEffect);

        nodeToUnmountEffectMap.set(node, unmountEffect); // Unmount Effect 一覧に追加
        key !== undefined && newKeyToNodeModMap.set(key, {node, mod}); // {node, mod} をマップに追加 (key が存在する場合のみ)
      }

      mod(item)(); // Mod に item を適用 (ここで Signal の更新処理をする)

      // 以下 作成、または前回から引き継いだ node を目的の場所に移動する処理
      if (itr !== null) {
        // itr が 存在するなら、新しい Node を挿入する場所は itr の直前である。
        if (itr === node) {
          // ただし、itr が Node と同じだった場合、itr は次の Node に移動して、新しく挿入することはない (レンダーコスト低減のため)
          itr = itr.nextSibling;
        } else {
          parentElement.insertBefore(node, itr);
        }
      } else {
        // itr が存在しないなら、新しい Node を挿入する場所は parentNode の最後である。
        parentElement.appendChild(node);
      }
    });

    // Node を削除する処理
    willUnmountNodes.forEach((node) => {
      const unmountEffect = nodeToUnmountEffectMap.get(node); // 先に unmount Effect を取得しておく
      nodeToUnmountEffectMap.delete(node); // nodeToUnmountEffectMap から対象の Node を削除
      unmountEffect(); // Unmount Effect を実行
      node.remove(); // Node を削除
    });

    useChildComponentsState.keyToNodeModMap = newKeyToNodeModMap; // keyToNodeModMap を更新
  };
