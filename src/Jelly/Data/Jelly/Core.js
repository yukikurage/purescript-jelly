"use strict"

/*
Manage observedState-observer dependencies
*/

export const newObserver = (f /* :: Observer -> Effect Unit */) => () => {
  const observer = {
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

export const getObserverEffect = (observer) => observer.effect

export const getObservers = (observedState) => () => {
  return [...observedState];
};
