export const setInnerHTML = (str) => (elem)  => () => {
  elem.innerHTML = str;
}
