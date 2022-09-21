const __jelly_data: Map<string, string> = new Map();

export const getDataImpl =
  <T>(just: (data: string) => T) =>
  (nothing: T) =>
  (key: string) =>
  (): T => {
    const data = __jelly_data.get(key);
    if (data === undefined) {
      return nothing;
    } else {
      return just(data);
    }
  };

export const setData = (key: string) => (value: string) => () => {
  __jelly_data.set(key, value);
};
