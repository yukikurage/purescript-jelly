export const newEmitterListener = (f) => () => {
  return (e) => f(e);
};

export const newEmitter = () => {
  return new Set();
};

export const addEmitterListener = (emitter) => (listener) => () => {
  emitter.add(listener);
};

export const removeEmitterListener = (emitter) => (listener) => () =>  {
  emitter.delete(listener);
};

export const emit = (emitter) => (event) =>
  [...emitter].map((listener) => listener(event));

export const removeAllEmitterListeners = (emitter) => () => {
  emitter.clear();
};
