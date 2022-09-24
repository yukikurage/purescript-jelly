"use strict";

type Atom<T> = {
  value: T;
  observers: Set<Observer<T>>;
};

type Effect<T> = () => T;

type Listener<T> = (value: T) => Effect<Effect<void>>;

type Observer<T> = {
  listener: Listener<T>;
  cleaner: Effect<void>;
};

export const newAtom =
  <T>(value: T): Effect<Atom<T>> =>
  () => ({
    value,
    observers: new Set<Observer<T>>(),
  });

export const listenAtom =
  <T>(atom: Atom<T>) =>
  (listener: Listener<T>): Effect<Effect<void>> =>
  () => {
    const observer: Observer<T> = {
      listener,
      cleaner: listener(atom.value)(),
    };
    atom.observers.add(observer);
    return () => {
      atom.observers.delete(observer);
      observer.cleaner();
    };
  };

export const writeAtomImpl =
  <T>(atom: Atom<T>) =>
  (value: T): Effect<void> =>
  () => {
    atom.value = value;
    atom.observers.forEach((observer) => {
      observer.cleaner();
      observer.cleaner = observer.listener(value)();
    });
  };

export const readAtom =
  <T>(atom: Atom<T>): Effect<T> =>
  () =>
    atom.value;
