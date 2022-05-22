export const newEmitter = () => {
  return new Set();
};

export const addEmitterListener = (emitter) => (listener) => () => {
  const registrationId = (e) => listener(e)
  emitter.add(registrationId)
  return registrationId
};

export const addEmitterListenerOnce = (emitter) => (listener) => () => {
  const registrationId = (e) => {
    emitter.delete(registrationId);
    return listener(e);
  };
  emitter.add(registrationId);
  return registrationId;
};

export const removeEmitterListener = (emitter) => (registrationId) => () =>  {
  emitter.delete(registrationId);
};

export const emitImpl = (emitter) => (event) => () =>
  [...emitter].map((listener) => listener(event));

export const removeAllEmitterListeners = (emitter) => () => {
  emitter.clear();
};
