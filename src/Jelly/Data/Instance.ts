type NodeJSInstance = NodeJSElementInstance | NodeJSTextInstance;

type NodeJSElementInstance = {
  tagName: string;
  attributes: Record<string, string>;
  children: NodeJSInstance[];
};

type NodeJSTextInstance = { text: string };

const isBrowser = typeof window !== "undefined";

type BrowserInstance = Element | Text;

type Instance = NodeJSInstance | BrowserInstance;

export const newInstance = (tagName: string) => (): Instance => {
  if (isBrowser) {
    return document.createElement(tagName);
  }
  return {
    tagName,
    attributes: {},
    children: [],
  };
};

export const newTextInstance = (text: string) => (): Instance => {
  if (isBrowser) {
    return document.createTextNode(text);
  }
  return { text };
};

export const setAttribute =
  (name: string) => (value: string) => (instance: Instance) => () => {
    if (isBrowser && instance instanceof Element) {
      instance.setAttribute(name, value);
    }
    if (!isBrowser && !("text" in instance)) {
      (instance as NodeJSElementInstance).attributes[name] = value;
    }
  };

export const removeAttribute = (name: string) => (instance: Instance) => () => {
  if (isBrowser && instance instanceof Element) {
    instance.removeAttribute(name);
  }
  if (!isBrowser && !("text" in instance)) {
    delete (instance as NodeJSElementInstance).attributes[name];
  }
};

export const updateChildren =
  (children: Instance[]) => (instance: Instance) => () => {
    if (isBrowser) {
      const browserInstance = instance as BrowserInstance;
      const browserChildren = children as BrowserInstance[];
      const prevNodes = Array.from(browserInstance.childNodes);
      const nodesSet = new Set(browserChildren);
      const nodesToRemove = prevNodes.filter(
        (node) => !nodesSet.has(node as Element)
      );
      nodesToRemove.forEach((node) => browserInstance.removeChild(node));
      let itrNode = browserInstance.firstChild;
      for (const node of browserChildren) {
        if (itrNode === node) {
          itrNode = itrNode.nextSibling;
          continue;
        }
        if (itrNode === null) {
          browserInstance.appendChild(node);
          continue;
        }
        browserInstance.insertBefore(node, itrNode);
      }
      return;
    }
    if (!isBrowser && !("text" in instance)) {
      (instance as NodeJSElementInstance).children =
        children as NodeJSInstance[];
    }
  };

export const toHTMLImpl = (instance: Instance) => (): string => {
  if (isBrowser) {
    throw new Error("Not implemented");
  }
  if (!isBrowser && !("text" in instance)) {
    const node = instance as NodeJSElementInstance;
    const attributes = Object.entries(node.attributes)
      .map(([name, value]) => ` ${name}="${value}"`)
      .join("");
    const children = node.children.map((inst) => toHTMLImpl(inst)()).join("");
    return `<${node.tagName}${attributes}>${children}</${node.tagName}>`;
  }
  return (instance as NodeJSTextInstance).text;
};

export const addEventListenerImpl =
  (eventType: string) =>
  (listener: (e: Event) => () => void) =>
  (instance: Instance) =>
  () => {
    if (isBrowser) {
      const l = (e: Event) => listener(e)();
      (instance as BrowserInstance).addEventListener(eventType, l);
      return () => {
        (instance as BrowserInstance).removeEventListener(eventType, l);
      };
    }
  };

export const setTextContent = (text: string) => (instance: Instance) => () => {
  if (isBrowser) {
    (instance as BrowserInstance).textContent = text;
  }
  if (!isBrowser && "text" in instance) {
    (instance as NodeJSTextInstance).text = text;
  }
};

export const setInnerHTML = (html: string) => (instance: Instance) => () => {
  if (isBrowser && instance instanceof Element) {
    instance.innerHTML = html;
  }
  if (!isBrowser && !("text" in instance)) {
    (instance as NodeJSElementInstance).children = [{ text: html }];
  }
};
