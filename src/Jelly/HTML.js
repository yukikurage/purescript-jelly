export const updateNodeChildren = (node) => (childNodes) => () => {
  let itr = node.firstChild;

  childNodes.map((childNode) => {
    if (itr !== null) {
      if (itr === childNode) {
        itr = itr.nextSibling;
        return;
      }
      node.insertBefore(childNode, itr);
    } else {
      node.appendChild(childNode);
    }
  });

  while (itr !== null) {
    const next = itr.nextSibling;
    node.removeChild(itr);
    itr = next;
  }
};
