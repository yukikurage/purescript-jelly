export const windowMaybeImpl = (just) => (nothing) => () => {
  if (typeof window !== "undefined") {
    return just(window);
  }
  return nothing;
}
