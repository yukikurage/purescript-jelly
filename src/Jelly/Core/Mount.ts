type Effect<T> = () => T;

export const updateChildren =
  (elem: Element) =>
  (children: Array<Node>): Effect<void> =>
  () => {
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

export const createDocumentType =
  (name: string) =>
  (publicId: string) =>
  (systemId: string) =>
  (doc: Document) =>
  () =>
    doc.implementation.createDocumentType(name, publicId, systemId);

export const setInnerHtml =
  (elem: Element) =>
  (html: string): Effect<void> =>
  () => {
    elem.innerHTML = html;
  };
