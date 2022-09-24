"use strict";
export const newAtom = (value) => () => ({
    value,
    observers: new Set(),
});
export const listenAtom = (atom) => (listener) => () => {
    const observer = {
        listener,
        cleaner: listener(atom.value)(),
    };
    atom.observers.add(observer);
    return () => {
        atom.observers.delete(observer);
        observer.cleaner();
    };
};
export const writeAtomImpl = (atom) => (value) => () => {
    atom.value = value;
    atom.observers.forEach((observer) => {
        observer.cleaner();
        observer.cleaner = observer.listener(value)();
    });
};
export const readAtom = (atom) => () => atom.value;
