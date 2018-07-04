import Foundation

public protocol InfosetSelector {}
extension Int: InfosetSelector {}
extension String: InfosetSelector {}
extension XMLTools.QName: InfosetSelector {}

/**
 Provides high-level, extensible API to read and manipulate the XML structures.
 Every Infoset is represented by zero or more "selected" context nodes (e.g. Document).
 Most of the functions take effect on every context node, the same way XPath and XSLT
 work.
 */
public class Infoset : Sequence {
    public typealias XMLElement = XMLTools.Element

    open static let EMPTY = Infoset()

    open var selectedNodes: [Node]
    open var parentDocument: Document
    
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

    public func makeIterator() -> SelectionIterator {
        return SelectionIterator(base: self)
    }
    
    public var namespaceContext : NamespaceContext {
        get {
            return document().namespaceContext
        }
        set (context) {
            document().namespaceContext = context
        }
    }
    
    open func childNodes() -> [Node] {
        var result = [Node]()
        for node in selectedNodes {
            result.append(contentsOf: node.childNodes)
        }
        return result
    }

    open func selectedElements() -> [XMLElement] {
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

    /**
     Selects all child nodes of every context node
     */
    public func select() -> Infoset {
        return Infoset(childNodes(), from: parentDocument)
    }

    /**
     Selects all child nodes of every context node which have the given (unqualified) name,
     continues this operation for every name
    */
    public func select(_ names: String...) -> Infoset {
        var selection = self
        for name in names {
            selection = selection.select(name)
            if selection.count == 0 {
                break
            }
        }
        return selection
    }

    /**
     Selects all child nodes of every context node which have the given qualified name,
     repeats this operation for every given qname
     */
    public func select(_ qnames: QName...) -> Infoset {
        var selection = self
        for qname in qnames {
            selection = selection.select(qname)
            if selection.count == 0 {
                break
            }
        }
        return selection
    }

    public func select(_ selectors:InfosetSelector... ) -> Infoset {
        return select(selectors)
    }

    public func select(_ selectors:[InfosetSelector]) -> Infoset {
        var selection = self
        for selector in selectors {
            selection = selection.select(selector)
        }
        return selection
    }
    
    /**
     Returns n-th node of this infoset as the new infoset with only one node
    */
    public func item(_ index: Int) -> Infoset {
        if index < selectedNodes.count {
            return Infoset(selectedNodes[index])
        }
        return Infoset.EMPTY
    }
    
    public func select(_ name: String) -> Infoset {
        return select(resolveQName(name))
    }

    public func select(_ qname: QName) -> Infoset {
        var matches = [Node]()
        for node in selectedNodes {
            for child in node.childNodes {
                if child.name() == qname && child as? XMLElement != nil {
                    matches.append(child)
                }
            }
        }
        return Infoset(matches, from: document())
    }

    public func select(_ selector: InfosetSelector) -> Infoset {
        switch selector {
        case let index as Int:
            return item(index)
        case let name as String:
            return select(name)
        case let qname as XMLTools.QName:
            return select(qname)
        default:
            return Infoset.EMPTY
        }
    }
    
    public func select(byPosition conditionMatch: (Int) -> Bool) -> Infoset {
        var pos = 0
        var matches = [Node]()
        for node in selectedNodes {
            if conditionMatch(pos) {
                matches.append(node)
            }
            pos = pos + 1
        }
        return Infoset(matches, from: document())
    }

    public func select(_ conditionMatch: (Infoset) -> Bool) -> Infoset {
        var matches = [Node]()
        for node in selectedNodes {
            if conditionMatch(Infoset(node)) {
                matches.append(node)
            }
        }
        return Infoset(matches, from: document())
    }

    public func selectNode() -> Infoset {
        return Infoset(childNodes(), from: document())
    }
        
    public func document() -> Document {
        return parentDocument
    }
    
    public func selectDocument() -> Infoset {
        return Infoset(document())
    }
    
    public func name() -> QName {
        if selectedNodes.count == 1 {
            if let qname = selectedNodes[0].name() {
                return qname
            }
        }
        return QName("")
    }
    
    public subscript (selector: InfosetSelector) -> Infoset {
        return select(selector)
    }

    public subscript (selectors: InfosetSelector...) -> Infoset {
        return select(selectors)
    }

    public subscript (selectors: [InfosetSelector]) -> Infoset {
        return select(selectors)
    }
    
    public var count: Int {
        get {
            return selectedNodes.count
        }
    }
    
    public func last() -> Infoset {
        if let lastNode = selectedNodes.last {
            return Infoset(lastNode)
        }
        return Infoset.EMPTY
    }
    
    open func merge(with otherSelection: Infoset) {
        selectedNodes.append(contentsOf: otherSelection.selectedNodes)
    }
    
    open func append(_ node: XMLTools.Node) {
        selectedNodes.append(node)
    }

    open func append(contentsOf nodes: [XMLTools.Node]) {
        selectedNodes.append(contentsOf: nodes)
    }

}

public struct SelectionIterator : IteratorProtocol {
    public typealias Element = Infoset
    
    var index = -1
    let nodes: [Node]
    
    init(base: Infoset) {
        nodes = base.selectedNodes
    }
    
    public mutating func next() -> Infoset? {
        index = index + 1
        if index < nodes.count {
            return Infoset(nodes[index])
        }
        return nil
    }

}

extension XMLTools.Node {
    
    public func select() -> Infoset {
        return Infoset(self)
    }
    
}
