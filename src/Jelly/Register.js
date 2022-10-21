export const updateChildren = (elem) => (children) => () => {
    const prevNodes = Array.from(elem.childNodes);
    const nodesSet = new Set(children);
    const nodesToRemove = prevNodes.filter((node) => !nodesSet.has(node));
    nodesToRemove.forEach((node) => elem.removeChild(node));
    let itrNode = elem.firstChild;
    for (const node of children) {
        if (itrNode === node) {
            itrNode = itrNode.nextSibling;
            continue;
        }
        if (itrNode === null) {
            elem.appendChild(node);
            continue;
        }
        elem.insertBefore(node, itrNode);
    }
};
