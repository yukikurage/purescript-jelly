export const newEmitter = () => new Set();
export const addListener = (e) => (l) => () => e.add(l);
export const emit = (e) => () => {
    for (const l of e) {
        l();
        e.delete(l);
    }
};
