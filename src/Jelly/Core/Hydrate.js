export const createDocumentType = (name) => (publicId) => (systemId) => (doc) => () => doc.implementation.createDocumentType(name, publicId, systemId);
