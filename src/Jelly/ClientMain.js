const __jelly_data = new Map();
export const getDataImpl = (just) => (nothing) => (key) => () => {
    const data = __jelly_data.get(key);
    if (data === undefined) {
        return nothing;
    }
    else {
        return just(data);
    }
};
export const setData = (key) => (value) => () => {
    __jelly_data.set(key, value);
};
