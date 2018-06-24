import Foundation

class Node {
    let parentNode: Node?
    var childNodes = [Node]()
    
    init(parent: Node?) {
        self.parentNode = parent
    }
    
    func name() -> QName? {
        return nil
    }
    
    func parentDocument() -> Document? {
        var node: Node? = self
        while (node != nil ) {
            if let doc = node as? Document {
                return doc
            }
            node = node?.parentNode
        }
        return nil
    }
}

class NamedNode : Node {
    let nodeName : QName
    
    init (parent:Node, name: QName) {
        self.nodeName = name
        super.init(parent: parent)
    }
    
    override func name() -> QName {
        return nodeName
    }
    
}

class Attribute : NamedNode {
    var value : String?;
    
    override init (parent: Node, name:QName) {
        super.init(parent: parent, name: name)
    }
    init (parent: Node, name:QName, value:String) {
        self.value = value
        super.init(parent: parent, name: name)
    }
    
}

class Element: NamedNode {
    lazy var attributes = [QName:Attribute]()
    internal lazy var prefixMapping = [String:String]()
    
    
    @discardableResult
    func appendElement(_ name: String) -> Element {
        return appendElement(QName(name))
    }
    
    @discardableResult
    func appendElement(_ name: QName) -> Element {
        let element = Element(parent: self, name: name);
        childNodes.append(element)
        return element
    }
    
    @discardableResult
    func appendAttribute(_ name: String, withValue value: String) -> Attribute {
        return appendAttribute(QName(name), withValue: value)
    }
    
    @discardableResult
    func appendAttribute(_ name: String, withNamespace namespaceURI: String, andValue value: String) -> Attribute {
        return appendAttribute(QName(name, uri: namespaceURI), withValue: value)
    }
    
    @discardableResult
    func appendAttribute(_ name: QName, withValue value: String) -> Attribute {
        let attr = Attribute(parent: self, name: name, value:value)
        attributes[attr.nodeName] = attr
        return attr
    }
    
    @discardableResult
    func appendText(_ text:String) -> TextNode {
        let node = TextNode(parent: self, value: text)
        childNodes.append(node)
        return node
    }
    
}

class TextNode: Node, Hashable {
    let value : String
    
    init (parent: Node, value: String) {
        self.value = value
        super.init(parent: parent)
    }
    
    static func == (lhs: TextNode, rhs: TextNode) -> Bool {
        return lhs.value == rhs.value
    }
    
    var hashValue: Int {
        return value.hashValue
    }
    
}

class Document: Node {
    var documentElement : Element?
    var namespaceContext = NamespaceContext()
    
    init () {
        super.init(parent: nil)
    }
    
    @discardableResult
    func appendElement(_ name: String) -> Element {
        return appendElement(QName(name))
    }
    
    func appendElement(_ name: QName) -> Element {
        childNodes.removeAll()
        let element = Element(parent: self, name: name);
        childNodes.append(element)
        documentElement = element
        return element
    }
    
}
