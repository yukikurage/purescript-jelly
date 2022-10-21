export const createDocumentType =
  (name: string) =>
  (publicId: string) =>
  (systemId: string) =>
  (doc: Document) =>
  () =>
    doc.implementation.createDocumentType(name, publicId, systemId);

export const convertInnerHtmlToNodes = (innerHtml: string) => () => {
  const div = document.createElement("div");
  div.innerHTML = innerHtml;
  return Array.from(div.childNodes);
};
