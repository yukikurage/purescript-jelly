"use strict";

export const newReceptor = (effect) => () => {
  return {
    children: new Set(),
    effect,
    callback: () => {},
  };
};

export const newSignal = () => new Set();

export const connect = (receptor) => (signal) => () => {
  receptor.children.add(signal);
  signal.add(receptor);
};

export const disconnect = (receptor) => (signal) => () => {
  receptor.children.delete(signal);
  signal.delete(receptor);
};

export const getEffect = (receptor) => () => {
  return receptor.effect;
};

export const getCallback = (receptor) => () => {
  return receptor.callback;
};

export const setCallback = (receptor) => (callback) => () => {
  receptor.callback = callback;
};

export const getReceptors = (signal) => () => {
  return [...signal];
};

export const getSignals = (receptor) => () => {
  return [...receptor.children];
};
