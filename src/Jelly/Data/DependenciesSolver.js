/*
Manage observedState-observer dependencies
*/

export const newObserverImpl = (f /* :: Observer m -> m (m Unit) */) => () => {
  const observer = {
    callback: undefined, // :: m Unit | undefined
    dependencies: new Set(),
  };
  observer.effect = f(observer); // :: m (m Unit)
  return observer;
};

export const newObservedStateImpl = () => new Set()

export const connectImpl = (observer) => (observedState) => () => {
  observer.dependencies.add(observedState);
  observedState.add(observer);
};

export const disconnectImpl = (observer) => (observedState) => () => {
  observer.dependencies.delete(observedState);
  observedState.delete(observer);
};

export const disconnectAllImpl = (observer) => () => {
  observer.dependencies.forEach((observedState) => {
    disconnectImpl(observer)(observedState);
  });
};

export const setObserverCallbackImpl = (observer) => (callback) => () => {
  observer.callback = callback;
};

export const getObserverCallbackImpl = (just) => (nothing) => (observer) => () => {
  if (observer.callback) {
    return just(observer.callback);
  } else {
    return nothing;
  }
}

export const getObserverEffect = (observer) => observer.effect

export const getObserversImpl = (observedState) => () => {
  return [...observedState];
};
