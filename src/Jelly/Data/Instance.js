const isBrowser = typeof window !== "undefined";
export const newInstance = (tagName) => () => {
    if (isBrowser) {
        return document.createElement(tagName);
    }
    return {
        tagName,
        attributes: {},
        children: [],
    };
};
export const newTextInstance = (text) => () => {
    if (isBrowser) {
        return document.createTextNode(text);
    }
    return { text };
};
export const newDocTypeInstance = () => {
    if (isBrowser) {
        return document.implementation.createDocumentType("html", "", "");
    }
    return { type: "DocType" };
};
export const setAttribute = (name) => (value) => (instance) => () => {
    if (isBrowser && instance instanceof Element) {
        instance.setAttribute(name, value);
    }
    if (!isBrowser && "tagName" in instance) {
        instance.attributes[name] = value;
    }
};
export const removeAttribute = (name) => (instance) => () => {
    if (isBrowser && instance instanceof Element) {
        instance.removeAttribute(name);
    }
    if (!isBrowser && "tagName" in instance) {
        delete instance.attributes[name];
    }
};
export const updateChildren = (children) => (instance) => () => {
    if (isBrowser) {
        const browserInstance = instance;
        const browserChildren = children;
        const prevNodes = Array.from(browserInstance.childNodes);
        const nodesSet = new Set(browserChildren);
        const nodesToRemove = prevNodes.filter((node) => !nodesSet.has(node));
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
    if (!isBrowser && "tagName" in instance) {
        instance.children =
            children;
    }
};
export const toHTMLImpl = (instance) => () => {
    if (isBrowser) {
        throw new Error("Not implemented");
    }
    if (!isBrowser && "tagName" in instance) {
        const node = instance;
        const attributes = Object.entries(node.attributes)
            .map(([name, value]) => ` ${name}="${value}"`)
            .join("");
        const children = node.children.map((inst) => toHTMLImpl(inst)()).join("");
        return `<${node.tagName}${attributes}>${children}</${node.tagName}>`;
    }
    if (!isBrowser && "text" in instance) {
        return instance.text;
    }
    return "<!DOCTYPE html>";
};
export const addEventListenerImpl = (eventType) => (listener) => (instance) => () => {
    if (isBrowser) {
        const l = (e) => listener(e)();
        instance.addEventListener(eventType, l);
        return () => {
            instance.removeEventListener(eventType, l);
        };
    }
};
export const setTextContent = (text) => (instance) => () => {
    if (isBrowser) {
        instance.textContent = text;
    }
    if (!isBrowser && "text" in instance) {
        instance.text = text;
    }
};
export const setInnerHTML = (html) => (instance) => () => {
    if (isBrowser && instance instanceof Element) {
        instance.innerHTML = html;
    }
    if (!isBrowser && "tagName" in instance) {
        instance.children = [{ text: html }];
    }
};
