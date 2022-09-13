"use strict";

type Observer = {
  signal: (observer: Observer) => () => void;
  callbacks: Set<() => void>;
};

type Atom<T> = {
  observers: Set<Observer>;
  value: T;
};

export const connect =
  (observer: Observer) =>
  <T>(atom: Atom<T>) =>
  () => {
    atom.observers.add(observer);
  };

export const disconnect =
  (observer: Observer) =>
  <T>(atom: Atom<T>) =>
  () => {
    atom.observers.delete(observer);
  };

export const newAtom =
  <T>(value: T) =>
  (): Atom<T> => ({
    observers: new Set(),
    value,
  });

export const newObserver =
  (signal: (observer: Observer) => () => void) => (): Observer => ({
    signal,
    callbacks: new Set(),
  });

export const getObservers =
  <T>(atom: Atom<T>) =>
  (): Observer[] =>
    [...atom.observers];

export const getAtomValue =
  <T>(atom: Atom<T>) =>
  (): T =>
    atom.value;

export const setAtomValue =
  <T>(atom: Atom<T>) =>
  (value: T) =>
  () => {
    atom.value = value;
  };

export const getObserverSignal = (observer: Observer) => () => observer.signal;

export const getObserverCallbacks = (observer: Observer) => () =>
  [...observer.callbacks];

export const addObserverCallback =
  (observer: Observer) => (callback: () => void) => () => {
    observer.callbacks.add(callback);
  };

export const clearObserverCallbacks = (observer: Observer) => () => {
  observer.callbacks.clear();
};
