export const createDocumentType =
  (name: string) =>
  (publicId: string) =>
  (systemId: string) =>
  (doc: Document) =>
  () =>
    doc.implementation.createDocumentType(name, publicId, systemId);
