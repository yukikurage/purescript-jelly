export const createDocumentType = (name) => (publicId) => (systemId) => (doc) => () => doc.implementation.createDocumentType(name, publicId, systemId);
export const convertInnerHtmlToNodes = (innerHtml) => () => {
    const div = document.createElement("div");
    div.innerHTML = innerHtml;
    return Array.from(div.childNodes);
};
