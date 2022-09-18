type NodeJSInstance =
  | NodeJSElementInstance
  | NodeJSTextInstance
  | NodeJSHtmlDocTypeInstance;

type NodeJSElementInstance = {
  type: "ELEMENT";
  tagName: string;
  attributes: Record<string, string>;
  children: NodeJSInstance[];
};

type NodeJSTextInstance = { type: "TEXT"; text: string };

type NodeJSHtmlDocTypeInstance = {
  type: "DOCTYPE";
  qualifiedName: string;
  publicId: string;
  systemId: string;
};

type BrowserInstance = Element | Text | DocumentType;

type Instance =
  | {
      type: "NODE";
      instance: NodeJSInstance;
    }
  | {
      type: "BROWSER";
      instance: BrowserInstance;
    };

const isBrowser = typeof window !== "undefined";

export const newInstance = (tagName: string) => (): Instance => {
  if (isBrowser) {
    return {
      type: "BROWSER",
      instance: document.createElement(tagName),
    };
  } else {
    return {
      type: "NODE",
      instance: {
        type: "ELEMENT",
        tagName,
        attributes: {},
        children: [],
      },
    };
  }
};

export const newTextInstance = (text: string) => (): Instance => {
  if (isBrowser) {
    return {
      type: "BROWSER",
      instance: document.createTextNode(text),
    };
  }
  return {
    type: "NODE",
    instance: {
      type: "TEXT",
      text,
    },
  };
};

export const newDocTypeInstance =
  (qualifiedName: string) =>
  (publicId: string) =>
  (systemId: string) =>
  (): Instance => {
    if (isBrowser) {
      const docTypeNode = document.implementation.createDocumentType(
        qualifiedName,
        publicId,
        systemId
      );
      return {
        type: "BROWSER",
        instance: docTypeNode,
      };
    }
    return {
      type: "NODE",
      instance: {
        type: "DOCTYPE",
        qualifiedName,
        publicId,
        systemId,
      },
    };
  };

export const setAttribute =
  (name: string) => (value: string) => (instance: Instance) => () => {
    if (instance.type === "BROWSER" && instance.instance instanceof Element) {
      instance.instance.setAttribute(name, value);
    }
    if (instance.type === "NODE" && "tagName" in instance.instance) {
      instance.instance.attributes[name] = value;
    }
  };

export const removeAttribute = (name: string) => (instance: Instance) => () => {
  if (instance.type === "BROWSER" && instance.instance instanceof Element) {
    instance.instance.removeAttribute(name);
  }
  if (instance.type === "NODE" && "tagName" in instance.instance) {
    delete instance.instance.attributes[name];
  }
};

export const updateChildren =
  (children: Instance[]) => (instance: Instance) => () => {
    if (instance.type === "BROWSER" && instance.instance instanceof Element) {
      const browserChildren = children.map(
        ({ instance }) => instance as BrowserInstance
      );
      const prevNodes = Array.from(instance.instance.childNodes);
      const nodesSet = new Set(browserChildren);
      const nodesToRemove = prevNodes.filter(
        (node) => !nodesSet.has(node as Element)
      );
      nodesToRemove.forEach((node) => instance.instance.removeChild(node));
      let itrNode = instance.instance.firstChild;
      for (const node of browserChildren) {
        if (itrNode === node) {
          itrNode = itrNode.nextSibling;
          continue;
        }
        if (itrNode === null) {
          instance.instance.appendChild(node);
          continue;
        }
        instance.instance.insertBefore(node, itrNode);
      }
    }
    if (instance.type === "NODE" && instance.instance.type === "ELEMENT") {
      const nodeChildren = children.map(
        ({ instance }) => instance as NodeJSInstance
      );
      instance.instance.children = nodeChildren;
    }
  };

export const toHTMLImpl = (instance: Instance) => (): string => {
  if (instance.type === "BROWSER") {
    if (instance.instance instanceof Element) {
      return instance.instance.outerHTML;
    }
    if (instance.instance instanceof Text) {
      return instance.instance.textContent ?? "";
    }
    if (instance.instance instanceof DocumentType) {
      return `<!DOCTYPE ${instance.instance.name}>`;
    }
  }
  if (instance.type === "NODE") {
    if (instance.instance.type === "ELEMENT") {
      const attributes = Object.entries(instance.instance.attributes)
        .map(([name, value]) => ` ${name}="${value}"`)
        .join("");
      const children = instance.instance.children
        .map((child) => toHTMLImpl({ type: "NODE", instance: child })())
        .join("");
      return `<${instance.instance.tagName}${attributes}>${children}</${instance.instance.tagName}>`;
    }
    if (instance.instance.type === "TEXT") {
      return instance.instance.text;
    }
    if (instance.instance.type === "DOCTYPE") {
      if (
        instance.instance.publicId === "" &&
        instance.instance.systemId === ""
      ) {
        return `<!DOCTYPE ${instance.instance.qualifiedName}>`;
      }
      if (instance.instance.systemId === "") {
        return `<!DOCTYPE ${instance.instance.qualifiedName} PUBLIC "${instance.instance.publicId}">`;
      }
      return `<!DOCTYPE ${instance.instance.qualifiedName} PUBLIC "${instance.instance.publicId}" "${instance.instance.systemId}">`;
    }
  }
  return "";
};

export const addEventListenerImpl =
  (eventType: string) =>
  (listener: (e: Event) => () => void) =>
  (instance: Instance) =>
  () => {
    if (instance.type === "BROWSER") {
      const l = (e: Event) => listener(e)();
      instance.instance.addEventListener(eventType, l);
      return () => {
        instance.instance.removeEventListener(eventType, l);
      };
    }
  };

export const setTextContent = (text: string) => (instance: Instance) => () => {
  if (instance.type === "BROWSER") {
    instance.instance.textContent = text;
  }
  if (instance.type === "NODE" && instance.instance.type === "TEXT") {
    instance.instance.text = text;
  }
};

export const setInnerHTML = (html: string) => (instance: Instance) => () => {
  if (instance.type === "BROWSER" && instance.instance instanceof Element) {
    instance.instance.innerHTML = html;
  }
  if (instance.type === "NODE" && instance.instance.type === "ELEMENT") {
    instance.instance.children = [{ type: "TEXT", text: html }];
  }
};

export const toNodeImpl = (instance: Instance): Node => {
  if (instance.type === "BROWSER") {
    return instance.instance;
  }
  throw new Error("Unknown instance type");
};

export const fromNodeImpl = (node: Element | DocumentType | Text): Instance => {
  return {
    type: "BROWSER",
    instance: node,
  };
};
