"use strict";

type Unit = undefined;

type Effect<T> = () => T;

type Atom<T> = {
  eq: (a: T) => (b: T) => boolean;
  value: T; // mutable
  observers: Set<Observer<T>>; // mutable
};

type Listener<T> = (value: T) => Effect<Effect<Unit>>;

type Observer<T> = {
  cleaner: Effect<Unit>; // mutable
  listener: Listener<T>;
};

type Signal<T> = {
  get: () => T;
  listen: (listener: Listener<T>) => Effect<Effect<Unit>>; // return unlisten effect
};

export const newAtomImpl =
  <T>(value: T): Effect<Atom<T>> =>
  () => ({
    eq: () => () => false,
    value,
    observers: new Set<Observer<T>>(),
  });

export const newAtomEqImpl =
  <T>(eq: (a: T) => (b: T) => boolean) =>
  (value: T): Effect<Atom<T>> =>
  () => ({
    eq,
    value,
    observers: new Set<Observer<T>>(),
  });

export const subscribe = <T>(atom: Atom<T>): Signal<T> => ({
  get: () => atom.value,
  listen: (listener: Listener<T>) => () => {
    const observer = {
      cleaner: listener(atom.value)(), // Initialize Effect
      listener,
    };
    atom.observers.add(observer);
    return () => {
      atom.observers.delete(observer);
      observer.cleaner(); // Clean up Effect
      return undefined;
    };
  },
});

export const writeAtomImpl =
  <T>(atom: Atom<T>) =>
  (value: T): Effect<Unit> =>
  () => {
    if (atom.eq(atom.value)(value)) {
      return undefined;
    }
    atom.value = value;
    atom.observers.forEach((observer) => {
      observer.cleaner();
      observer.cleaner = observer.listener(value)();
    });
    return undefined;
  };

export const modifyAtomImpl =
  <T>(atom: Atom<T>) =>
  (f: (value: T) => T): Effect<T> =>
  () => {
    const value = f(atom.value);
    writeAtomImpl(atom)(value)();
    return value;
  };

export const readSignalImpl =
  <T>(signal: Signal<T>): Effect<T> =>
  () =>
    signal.get();

export const runSignalImpl = (
  signal: Signal<Effect<Effect<Unit>>>
): Effect<Effect<Unit>> => signal.listen((eff: Effect<Effect<Unit>>) => eff);

export const mapImpl =
  <T, U>(f: (t: T) => U) =>
  (signal: Signal<T>): Signal<U> => ({
    get: () => f(signal.get()),
    listen: (listener: Listener<U>) => signal.listen((t: T) => listener(f(t))),
  });

export const applyImpl =
  <T, U>(signalF: Signal<(t: T) => U>) =>
  (signalT: Signal<T>): Signal<U> => ({
    get: () => signalF.get()(signalT.get()),
    listen: (listener: Listener<U>) =>
      signalF.listen((f: (t: T) => U) =>
        signalT.listen((t: T) => listener(f(t)))
      ),
  });

export const pureImpl = <T>(value: T): Signal<T> => ({
  get: () => value,
  listen: (listener: Listener<T>) => listener(value),
});

export const bindImpl =
  <T, U>(signalT: Signal<T>) =>
  (f: (t: T) => Signal<U>): Signal<U> => ({
    get: () => f(signalT.get()).get(),
    listen: (listener: Listener<U>) =>
      signalT.listen((t: T) => f(t).listen(listener)),
  });
