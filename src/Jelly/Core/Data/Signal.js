"use strict";
export const connect = (observer) => (atom) => () => {
    atom.observers.add(observer);
};
export const disconnect = (observer) => (atom) => () => {
    atom.observers.delete(observer);
};
export const newAtom = (eq) => (value) => () => ({
    observers: new Set(),
    value,
    eq,
});
export const newObserver = (signal) => () => ({
    signal,
    callbacks: new Set(),
});
export const getObservers = (atom) => () => [...atom.observers];
export const getAtomValue = (atom) => () => atom.value;
export const setAtomValue = (atom) => (value) => () => {
    atom.value = value;
};
export const getEq = (atom) => atom.eq;
export const getObserverSignal = (observer) => () => observer.signal;
export const getObserverCallbacks = (observer) => () => [...observer.callbacks];
export const addObserverCallback = (observer) => (callback) => () => {
    observer.callbacks.add(callback);
};
export const clearObserverCallbacks = (observer) => () => {
    observer.callbacks.clear();
};
