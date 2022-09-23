"use strict";

type Atom<T> = {
  value: T;
  listeners: Set<Listener<T>>;
  cleaners: Set<Effect<void>>;
};

type Effect<T> = () => T;

type Listener<T> = (value: T) => () => Effect<void>;

export const newAtom =
  <T>(value: T): Effect<Atom<T>> =>
  () => ({
    value,
    listeners: new Set<Listener<T>>(),
    cleaners: new Set<Effect<void>>(),
  });

export const listenAtom =
  <T>(atom: Atom<T>) =>
  (listener: Listener<T>): Effect<Effect<void>> =>
  () => {
    atom.listeners.add(listener);
    return () => {
      atom.listeners.delete(listener);
    };
  };

export const writeAtom =
  <T>(atom: Atom<T>) =>
  (value: T): Effect<void> =>
  () => {
    atom.cleaners.forEach((cleaner) => {
      cleaner();
    });
    atom.cleaners.clear();
    atom.value = value;
    atom.listeners.forEach((listener) => {
      const cleaner = listener(value)();
      atom.cleaners.add(cleaner);
    });
  };

export const readAtom =
  <T>(atom: Atom<T>): Effect<T> =>
  () =>
    atom.value;
