type Emitter = Set<() => void>;
type Listener = () => void;

export const newEmitter = (): Emitter => new Set();

export const addListener = (e: Emitter) => (l: Listener) => () => e.add(l);

export const emit = (e: Emitter) => () => {
  for (const l of e) {
    l();
    e.delete(l);
  }
};
