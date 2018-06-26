import Foundation

public protocol XMLSructSubscript {}
extension Int: XMLSructSubscript {}
extension String: XMLSructSubscript {}
extension XMLTools.QName: XMLSructSubscript {}

class Selection : Sequence {
    typealias XMLElement = XMLTools.Element

    static let EMPTY = Selection()

    var selectedNodes: [Node]
    var parentDocument: Document
    
    private init() {
        selectedNodes = [Node]()
        parentDocument = Document()
    }

    init(_ nodes: [Node], from document:Document) {
        selectedNodes = nodes
        parentDocument = document
    }

    init(_ node: Node) {
        selectedNodes = [node]
        if node.parentDocument() != nil {
            parentDocument = node.parentDocument()!
        } else if let docNode = node as? Document {
            parentDocument = docNode
        } else {
            parentDocument = Document()
        }
    }

    func makeIterator() -> SelectionIterator {
        return SelectionIterator(base: self)
    }
    
    var namespaceContext : NamespaceContext {
        get {
            return document().namespaceContext
        }
        set (context) {
            document().namespaceContext = context
        }
    }
    
    internal func childNodes() -> [Node] {
        var result = [Node]()
        for node in selectedNodes {
            result.append(contentsOf: node.childNodes)
        }
        return result
    }

    internal func selectedElements() -> [XMLElement] {
        var result = [XMLElement]()
        for node in selectedNodes {
            if let element = node as? XMLElement {
                result.append(element)
            }
        }
        return result
    }
    
    internal func nodeToText(_ node: Node) -> String {
        var result = ""
        if let text = node as? TextNode {
            result += text.value
        } else if let attribute = node as? Attribute {
            if let attrVal = attribute.value {
                result += attrVal
            }
        } else if let element = node as? XMLElement {
            for child in element.childNodes {
                result += nodeToText(child)
            }
        }
        return result
    }

    internal func resolveQName(_ name:String, resolveDefaultNamespace: Bool = true) -> QName {
        if name.range(of: ":") != nil {
            let tuple = name.components(separatedBy: ":")
            if let uri = namespaceContext[tuple[0]] {
                return QName(tuple[1], uri: uri)
            }
            return QName(tuple[1])
        } else if namespaceContext.defaultURI != nil && resolveDefaultNamespace {
            return QName(name, uri: namespaceContext.defaultURI!)
        }
        return QName(name)
        
    }

    public func select() -> Selection {
        return Selection(childNodes(), from: parentDocument)
    }

    public func select(_ names: String...) -> Selection {
        var selection = self
        for name in names {
            selection = selection.select(name)
            if selection.count == 0 {
                break
            }
        }
        return selection
    }

    public func select(_ qnames: QName...) -> Selection {
        var selection = self
        for qname in qnames {
            selection = selection.select(qname)
            if selection.count == 0 {
                break
            }
        }
        return selection
    }

    public func item(_ index: Int) -> Selection {
        if index < selectedNodes.count {
            return Selection(selectedNodes[index])
        }
        return Selection.EMPTY
    }
    
    public func select(_ name: String) -> Selection {
        return select(resolveQName(name))
    }

    public func select(_ qname: QName) -> Selection {
        var matches = [Node]()
        for node in selectedNodes {
            for child in node.childNodes {
                if child.name() == qname && child as? XMLElement != nil {
                    matches.append(child)
                }
            }
        }
        return Selection(matches, from: document())
    }

    public func select(byPosition conditionMatch: (Int) -> Bool) -> Selection {
        var pos = 0
        var matches = [Node]()
        for node in selectedNodes {
            if conditionMatch(pos) {
                matches.append(node)
            }
            pos = pos + 1
        }
        return Selection(matches, from: document())
    }

    public func select(_ conditionMatch: (Selection) -> Bool) -> Selection {
        var matches = [Node]()
        for node in selectedNodes {
            if conditionMatch(Selection(node)) {
                matches.append(node)
            }
        }
        return Selection(matches, from: document())
    }

    public func selectNode() -> Selection {
        return Selection(childNodes(), from: document())
    }
    
    /*
    public func child(_ index: Int) -> Selection {
        let children = childNodes()
        if index < children.count {
            return Selection(children[index])
        }
        return Selection.EMPTY
    }
    
    public func child(_ name: String) -> Selection {
        return child(resolveQName(name))
    }

    public func child(_ qname: QName) -> Selection {
        var matches = [Node]()
        for node in selectedNodes {
            for child in node.childNodes {
                if child.name() == qname {
                    matches.append(child)
                }
            }
        }
        return Selection(matches, from: document())
    }
    */
    
    public func document() -> XMLTools.Document {
        return parentDocument
    }
    
    public func selectDocument() -> Selection {
        return Selection(document())
    }
    
    public func name() -> XMLTools.QName {
        if selectedNodes.count == 1 {
            if let qname = selectedNodes[0].name() {
                return qname
            }
        }
        return XMLTools.QName("")
    }
    
    public subscript (selector: XMLSructSubscript) -> Selection {
        switch selector {
            case let index as Int:
                return item(index)
            case let name as String:
                return select(name)
            case let qname as XMLTools.QName:
                return select(qname)
            default:
                return Selection.EMPTY
        }
    }

    public subscript (selectors: XMLSructSubscript...) -> Selection {
        var selection = self
        for selector in selectors {
            selection = selection[selector]
        }
        return selection
    }

    public var count: Int {
        get {
            return selectedNodes.count
        }
    }
    
    public func last() -> Selection {
        if let lastNode = selectedNodes.last {
            return Selection(lastNode)
        }
        return Selection.EMPTY
    }
    
    internal func merge(with otherSelection: Selection) {
        selectedNodes.append(contentsOf: otherSelection.selectedNodes)
    }
    
    internal func append(_ node: XMLTools.Node) {
        selectedNodes.append(node)
    }

    internal func append(contentsOf nodes: [XMLTools.Node]) {
        selectedNodes.append(contentsOf: nodes)
    }

}

struct SelectionIterator : IteratorProtocol {
    typealias Element = Selection
    
    var index = -1
    let nodes: [Node]
    
    init(base: Selection) {
        nodes = base.selectedNodes
    }
    
    mutating func next() -> Selection? {
        index = index + 1
        if index < nodes.count {
            return Selection(nodes[index])
        }
        return nil
    }

}

extension XMLTools.Node {
    
    func select() -> Selection {
        return Selection(self)
    }
    
}
