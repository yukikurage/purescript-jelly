"use strict"

/*
Manage observedState-observer dependencies
*/

export const newObserver = (f /* :: Observer -> Effect Unit */) => () => {
  const observer = {
    callbacks: new Set(), // :: Set<() => void)>
    dependencies: new Set(),
  };
  observer.effect = f(observer); // :: Effect Unit
  return observer;
};

export const newObservedState = () => new Set()

export const connect = (observer) => (observedState) => () => {
  observer.dependencies.add(observedState);
  observedState.add(observer);
};

export const disconnect = (observer) => (observedState) => () => {
  observer.dependencies.delete(observedState);
  observedState.delete(observer);
};

export const disconnectAll = (observer) => () => {
  observer.dependencies.forEach((observedState) => {
    disconnect(observer)(observedState)();
  });
};

export const addObserverCallbacks = (observer) => (callback) => () => {
  observer.callbacks.add(callback);
};

export const clearObserverCallbacks = (observer) => () => {
  observer.callbacks.clear();
};

export const getObserverCallbacks =  (observer) => () => {
  return [...observer.callbacks];
}

export const getObserverEffect = (observer) => observer.effect

export const getObservers = (observedState) => () => {
  return [...observedState];
};
