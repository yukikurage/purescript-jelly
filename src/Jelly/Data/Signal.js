"use strict";

export const connect = (observer) => (atom) => () => {
  atom.observers.add(observer);
};

export const disconnect = (observer) => (atom) => () => {
  atom.observers.delete(observer);
};

export const newAtom = (value /* a */) => () => ({
  observers: new Set(),
  value,
});

export const newObserver =
  (signal /* :: Observer -> Effect (Effect Unit) */) => () => ({
    signal,
    callbacks: new Set(),
  });

export const getObservers = (atom /* :: Atom a */) => () =>
  [...atom.observers];

export const getAtomValue = (atom /* :: Atom a */) => () => atom.value;

export const setAtomValue =
  (atom /* :: Atom a */) => (value /* a */) => () => {
    atom.value = value;
  };

export const getObserverSignal = (observer /* :: Observer */) => () =>
  observer.signal;

export const getObserverCallbacks = (observer /* :: Observer */) => () =>
  [...observer.callbacks];

export const addObserverCallback = (observer /* :: Observer */) => (callback) => () => {
  observer.callbacks.add(callback);
}

export const clearObserverCallbacks = (observer /* :: Observer */) => () => {
  observer.callbacks.clear();
}
