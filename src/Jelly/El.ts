export const updateChildNodes =
  (nodes: Node[]) => (parent: ParentNode) => () => {
    const prevNodes = Array.from(parent.childNodes);
    const nodesSet = new Set(nodes);
    const nodesToRemove = prevNodes.filter((node) => !nodesSet.has(node));
    nodesToRemove.forEach((node) => parent.removeChild(node));

    let itrNode = parent.firstChild;
    for (const node of nodes) {
      if (itrNode === node) {
        itrNode = itrNode.nextSibling;
        continue;
      }
      if (itrNode === null) {
        parent.appendChild(node);
        continue;
      }
      parent.insertBefore(node, itrNode);
    }
  };
