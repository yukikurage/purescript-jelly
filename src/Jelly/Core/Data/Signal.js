"use strict";
export const newAtom = (value) => () => ({
    value,
    listeners: new Set(),
    cleaners: new Set(),
});
export const listenAtom = (atom) => (listener) => () => {
    atom.listeners.add(listener);
    return () => {
        atom.listeners.delete(listener);
    };
};
export const writeAtom = (atom) => (value) => () => {
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
export const readAtom = (atom) => () => atom.value;
