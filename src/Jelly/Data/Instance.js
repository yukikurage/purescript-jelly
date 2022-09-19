const isBrowser = typeof window !== "undefined";
export const newInstance = (tagName) => () => {
    if (isBrowser) {
        return {
            type: "BROWSER",
            instance: document.createElement(tagName),
        };
    }
    else {
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
export const newTextInstance = (text) => () => {
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
export const newDocTypeInstance = (qualifiedName) => (publicId) => (systemId) => () => {
    if (isBrowser) {
        const docTypeNode = document.implementation.createDocumentType(qualifiedName, publicId, systemId);
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
export const setAttribute = (name) => (value) => (instance) => () => {
    if (instance.type === "BROWSER" && instance.instance instanceof Element) {
        instance.instance.setAttribute(name, value);
    }
    if (instance.type === "NODE" && "tagName" in instance.instance) {
        instance.instance.attributes[name] = value;
    }
};
export const removeAttribute = (name) => (instance) => () => {
    if (instance.type === "BROWSER" && instance.instance instanceof Element) {
        instance.instance.removeAttribute(name);
    }
    if (instance.type === "NODE" && "tagName" in instance.instance) {
        delete instance.instance.attributes[name];
    }
};
export const updateChildren = (children) => (instance) => () => {
    if (instance.type === "BROWSER" && instance.instance instanceof Element) {
        const browserChildren = children.map(({ instance }) => instance);
        const prevNodes = Array.from(instance.instance.childNodes);
        const nodesSet = new Set(browserChildren);
        const nodesToRemove = prevNodes.filter((node) => !nodesSet.has(node));
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
        const nodeChildren = children.map(({ instance }) => instance);
        instance.instance.children = nodeChildren;
    }
};
export const toHTMLImpl = (instance) => () => {
    var _a;
    if (instance.type === "BROWSER") {
        if (instance.instance instanceof Element) {
            return instance.instance.outerHTML;
        }
        if (instance.instance instanceof Text) {
            return (_a = instance.instance.textContent) !== null && _a !== void 0 ? _a : "";
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
            if (instance.instance.publicId === "" &&
                instance.instance.systemId === "") {
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
export const addEventListenerImpl = (eventType) => (listener) => (instance) => () => {
    if (instance.type === "BROWSER") {
        const l = (e) => listener(e)();
        instance.instance.addEventListener(eventType, l);
        return () => {
            instance.instance.removeEventListener(eventType, l);
        };
    }
    return () => { };
};
export const setTextContent = (text) => (instance) => () => {
    if (instance.type === "BROWSER") {
        instance.instance.textContent = text;
    }
    if (instance.type === "NODE" && instance.instance.type === "TEXT") {
        instance.instance.text = text;
    }
};
export const setInnerHTML = (html) => (instance) => () => {
    if (instance.type === "BROWSER" && instance.instance instanceof Element) {
        instance.instance.innerHTML = html;
    }
    if (instance.type === "NODE" && instance.instance.type === "ELEMENT") {
        instance.instance.children = [{ type: "TEXT", text: html }];
    }
};
export const toNodeImpl = (instance) => {
    if (instance.type === "BROWSER") {
        return instance.instance;
    }
    throw new Error("Unknown instance type");
};
export const fromNodeImpl = (node) => {
    return {
        type: "BROWSER",
        instance: node,
    };
};
