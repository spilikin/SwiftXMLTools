//
//  DOM+Traversal.swift
//  XMLTools
//  
//  Created on 25.06.18
//

import Foundation

enum DocumentVisitorDecision {
    case stepIn
    case next
    case stop
    
}
protocol DocumentVisitor {
    func visit(_ document: Document) -> DocumentVisitorDecision
    func visit(_ element: Element, from document: Document) -> DocumentVisitorDecision
    func visit(_ textNode: TextNode, from document: Document) -> DocumentVisitorDecision
    func visit(_ cdata: CDATANode, from document: Document) -> DocumentVisitorDecision
    func visit(_ comment: CommentNode, from document: Document) -> DocumentVisitorDecision
}

extension Document {
    func traverse(visitor: DocumentVisitor) {
        if (visitor.visit(self) == .stepIn) {
            self.documentElement?.traverse(visitor: visitor, document: self)
        }
    }
    func traverse(handler: DocumentHandler) {
        handler.startDocument(self)
        documentElement?.traverse(handler: handler, document: self)
        handler.endDocument(self)
    }
}

protocol DocumentHandler {
    // Receive notification of a skipped entity.
    func startDocument(_ document: Document)
    // Receive notification of the end of a document.
    func endDocument(_ document: Document)
    // Receive notification of the beginning of a document.
    func startElement(_ element: Element, from document: Document)
    // Receive notification of the end of an element.
    func endElement(_ element: Element, from document: Document)
    // Receive notification of text in element content
    func textNode(_ textNode: TextNode, from document: Document)
    // Receive notification of CDATA in element content
    func cdata(_ cdata: CDATANode, from document: Document)
    // Receive notification of comment
    func comment(_ comment: CommentNode, from document: Document)
}

extension Element {
    @discardableResult
    internal func traverse(visitor:DocumentVisitor, document: Document) -> DocumentVisitorDecision {
        switch visitor.visit(self, from: document) {
        case .stepIn:
            
            switch traverseChildren(visitor: visitor, document: document) {
            case .stop:
                return .stop
            case .next, .stepIn:
                return .next
            }
        case .next:
            return .next
        case .stop:
            return .stop
        }
    }
    
    internal func traverseChildren(visitor:DocumentVisitor, document: Document) -> DocumentVisitorDecision {
        for node in childNodes {
            var decision:DocumentVisitorDecision
            switch node {
            case let element as Element:
                decision = visitor.visit(element, from: document)
                if decision == .stepIn {
                    decision = element.traverse(visitor: visitor, document: document)
                }
            case let textNode as TextNode:
                decision = visitor.visit(textNode, from: document)
            case let cdata as CDATANode:
                decision = visitor.visit(cdata, from: document)
            case let comment as CommentNode:
                decision = visitor.visit(comment, from: document)
            default:
                decision = .next
            }
            if decision == .stop {
                return .stop
            }
        }
        return .next
    }
    
    internal func traverse(handler:DocumentHandler, document: Document) {
        handler.startElement(self, from: document)
        for node in childNodes {
            switch node {
            case let element as Element:
                element.traverse(handler:handler, document: document)
            case let textNode as TextNode:
                handler.textNode(textNode, from: document)
            case let cdata as CDATANode:
                handler.cdata(cdata, from: document)
            case let comment as CommentNode:
                handler.comment(comment, from: document)
            default:
                break
            }
        }
        handler.endElement(self, from: document)
    }
}

