"use strict";

/*
Signal は同期関数を用いて、ある変数の操作を関連する変数に広げる
parentSignal は、値が更新された時に childSignal に通知をする
*/

/**
 * update は Signal を受け取って、a を返す Effect
 *  受け取った Signal に依存を追加する
 * eq は同値判定に使う関数
 *  同時に初期化も行う
 */
export const newSignalImpl =
  (update /* :: GenericSignal -> Effect a */) =>
  (eq /* :: a -> a -> Boolean */) =>
  () => {
    // 初期化
    const signal = {
      parentSignals: new Set(),
      childSignals: new Set(),
      eq,
    };

    signal.update = update(signal);

    // 値および依存関係の更新
    signal.value = signal.update();

    return signal;
  };

export const newRefImpl =
  (tuple) => (initValue) => (eq /* :: a -> a -> Boolean */) => () => {
    let value = initValue;

    const ref = {
      childSignals: new Set(),
    };

    const readRef = (childSignal /* :: GenericSignal */) => () => {
      connect(ref, childSignal);
      return value;
    };

    const writeRef = (newValue /* :: a */) => () => {
      // 前の値を保存しておく
      const oldValue = value;
      value = newValue;

      if (!eq(oldValue)(value)) {
        // 値が変化した場合、子の Signal を update する
        [...ref.childSignals].map((childSignal) => {
          updateSignalImpl(childSignal)();
        });
      }
    };

    return tuple(readRef)(writeRef);
  };

/**
 * Signal の value を読む時に依存関係を追加する
 */
export const readSignalImpl =
  (childSignal /* :: GenericSignal */) => (signal /* :: Signal a */) => () => {
    connect(signal, childSignal);
    return signal.value;
  };

export const readSignalAloneImpl = (signal /* :: Signal a */) => () => {
  return signal.value;
};

/**
 * Signal の Value を更新する
 * 葉の Signal や、外部の変数に依存する処理がある場合、
 * また、親の Signal が更新されたときに呼び出される
 */
export const updateSignalImpl = (signal /* :: Signal a */) => () => {
  // 依存関係を一度リセットする
  signal.parentSignals.map((parentSignal) => {
    disconnect(parentSignal, signal);
  });

  // 前の値を保存しておく
  const oldValue = signal.value;

  // 値および依存関係の更新
  signal.value = signal.update();

  if (!signal.eq(oldValue)(signal.value)) {
    // 値が変化した場合、子の Signal を update する
    [...signal.childSignals].map((childSignal) => {
      updateSignalImpl(childSignal)();
    });
  }
};

/**
 * Signal を親 Signal から切り離す
 * つまり、更新されなくなる
 * update によって再接続が可能
 */
export const disconnectSignalImpl = (signal /* :: Signal a */) => () => {
  signal.parentSignals.map((parentSignal) => {
    disconnect(parentSignal, signal);
  });
};

// Signal を接続
const connect = (parentSignal, childSignal) => {
  parentSignal.childSignals.add(childSignal);
  childSignal.parentSignals.add(parentSignal);
};

// Signal を切断
const disconnect = (parentSignal, childSignal) => {
  parentSignal.childSignals.delete(childSignal);
  childSignal.parentSignals.delete(parentSignal);
};
