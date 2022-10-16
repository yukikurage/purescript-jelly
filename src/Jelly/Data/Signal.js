"use strict";
export const atomImpl = (value) => () => ({
    eq: () => () => false,
    value,
    observers: new Set(),
});
export const atomWithEqImpl = (eq) => (value) => () => ({
    eq,
    value,
    observers: new Set(),
});
export const subscribe = (atom) => ({
    get: () => atom.value,
    listen: (listener) => () => {
        const observer = {
            cleaner: listener(atom.value)(),
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
export const sendImpl = (atom) => (value) => () => {
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
export const patchImpl = (atom) => (f) => () => {
    const value = f(atom.value);
    sendImpl(atom)(value)();
    return value;
};
export const getImpl = (signal) => () => signal.get();
export const runImpl = (signal) => signal.listen((eff) => eff);
export const mapImpl = (f) => (signal) => ({
    get: () => f(signal.get()),
    listen: (listener) => signal.listen((t) => listener(f(t))),
});
export const applyImpl = (signalF) => (signalT) => ({
    get: () => signalF.get()(signalT.get()),
    listen: (listener) => signalF.listen((f) => signalT.listen((t) => listener(f(t)))),
});
export const pureImpl = (value) => ({
    get: () => value,
    listen: (listener) => listener(value),
});
export const bindImpl = (signalT) => (f) => ({
    get: () => f(signalT.get()).get(),
    listen: (listener) => signalT.listen((t) => f(t).listen(listener)),
});