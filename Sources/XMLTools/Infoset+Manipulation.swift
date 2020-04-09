//
//  Infoset+Manipulation.swift
//  XMLTools
//
//  Created on 28.06.18
//

import Foundation

extension Infoset {

    /**
     Appends new element with given name to every currently selected element or document
     */
    @discardableResult
    public func appendElement(_ name: String) -> Infoset {
        return appendElement(safeResolveQName(name))
    }

    /**
     Appends new element qith given QName to every currently selected element or document
     */
    @discardableResult
    public func appendElement(_ qname: QName) -> Infoset {
        for node in selectedNodes {
            if let element = node as? Element {
                let newElement = element.appendElement(qname)
                return Infoset(newElement)
            } else if let document = node as? Document {
                let newElement = document.appendElement(qname)
                return Infoset(newElement)
            }
        }
        return .EMPTY
    }

    /**
     Removes the currently selected nodes from their corresponding parent(s)
     */
    @discardableResult
    public func remove() -> Infoset {
        let parentInfoset = parent()
        for node in selectedNodes {
            if let parentNode = node.parentNode {
                parentNode.childNodes = parentNode.childNodes.filter({ $0 !== node})
            }
        }
        return parentInfoset
    }

    /**
     Clears the currently selected nodes by removing their child nodes
     */
    @discardableResult
    public func clear() -> Infoset {
        for node in selectedNodes {
            node.childNodes.removeAll()
        }
        return self
    }

    /**
     Executes the given closure on this infoset allowing it to manipulate the XML
     */
    @discardableResult
    public func manipulate(_ closure: (Infoset) -> Void ) -> Infoset {
        closure(self)
        return self
    }

    /**
     Sets the value the attribute for every selected node
     */
    @discardableResult
    public func attr(_ name: String, setValue value: String) -> Infoset {
        return attr(safeResolveQName(name), setValue: value)
    }

    /**
     Sets the value the attribute for every selected node
     */
    @discardableResult
    public func attr(_ qname: QName, setValue value: String) -> Infoset {
        for node in selectedNodes {
            if let element = node as? Element {
                element.appendAttribute(qname, withValue: value)
            }
        }
        return attr(qname)
    }
}
