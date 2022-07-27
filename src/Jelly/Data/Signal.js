"use strict";

/*
Signal は時間変動する変数。変更された時に Observer に通知を送る。
*/

export const newSignalImpl = (value /* a */) => () => ({
  observers: new Set(),
  value,
});

export const newObserverImpl =
  (effect /* :: Observer -> Effect (Effect Unit) */) => () => {
    // 初期化
    const observer = {
      signals: new Set(),
    };

    observer.effect = effect(observer);

    // 依存関係、callback の更新
    observer.callback = observer.effect();

    return observer;
  };

/**
 * Observer を親 Observer から切り離す
 * つまり、更新されなくなる
 * update によって再接続が可能
 */
export const disconnectObserverImpl = (observer /* :: Observer */) => () => {
  observer.signals.map((signal) => {
    disconnect(observer, signal);
  });
};

// Signal を接続
const connect = (observer, signal) => {
  observer.signals.add(signal);
  signal.observers.add(observer);
};

// Signal を切断
const disconnect = (observer, signal) => {
  observer.signals.delete(signal);
  signal.observers.delete(observer);
};

export const readSignalImpl =
  (observer /* :: Observer */) => (signal /* :: Signal a */) => () => {
    connect(observer, signal);
    return signal.value;
  };

export const modifySignalImpl =
  (eq /* :: a -> a -> Boolean */) =>
  (signal /* :: Signal a */) =>
  (modifyFunction /* :: a -> a */) => {
    const oldValue = signal.value;

    const newValue = modifyFunction(oldValue);

    const oldObservers = [...signal.observers];

    if (!eq(oldValue)(newValue)) {
      // 値が変化した場合
      // callback を呼び出す
      oldObservers.map((observer) => {
        observer.callback();
      });
      // 値を書き換える
      signal.value = newValue;
      oldObservers.map((observer) => {
        // 古い依存関係を破棄する
        disconnectObserverImpl(observer)();
        // 依存関係と callback を更新する
        observer.callback = observer.effect();
      });
    }
  };

export const memoImpl =
  (eq /* :: a -> a -> Boolean */) =>
  (signalM /* :: Observer -> Effect {value :: a, callback :: Effect Unit }*/) =>
  () => {
    let state = undefined;

    const effect = (obs) => {
      const { value, callback } = signalM(obs)();
      if(state === undefined) {
        state = {
          observers: new Set(),
          value,
        }
      } else {
        modifySignalImpl(eq)(state)(() => value);
      }
      return callback;
    }

    return newObserverImpl(effect)();
  };
