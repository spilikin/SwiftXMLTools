//
//  DOM+Traversal.swift
//  XMLTools
//  
//  Created on 25.06.18
//

import Foundation

extension Document {
    func traverse(_ handler: DocumentHandler) throws {
        try handler.startDocument(self)
        try documentElement?.traverse(handler: handler, document: self)
        try handler.endDocument(self)
    }
}

public protocol DocumentHandler {
    // Receive notification of a skipped entity.
    func startDocument(_ document: Document) throws
    // Receive notification of the end of a document.
    func endDocument(_ document: Document) throws
    // Receive notification of the beginning of a document.
    func startElement(_ element: Element, from document: Document) throws
    // Receive notification of the end of an element.
    func endElement(_ element: Element, from document: Document) throws
    // Receive notification of text in element content
    func textNode(_ textNode: TextNode, from document: Document) throws
    // Receive notification of CDATA in element content
    func cdata(_ cdata: CDATANode, from document: Document) throws
    // Receive notification of comment
    func comment(_ comment: CommentNode, from document: Document) throws
    // Receive notification of a processing instruction.
    func processingInstruction(_ instruction: ProcessingInstruction, from document: Document) throws
}

/**
 Default implementation of `DocumentHandler` which does nothing
 */
public class DefaultDocumentHandler: DocumentHandler {

    public func startDocument(_ document: Document) throws {
    }
    
    public func endDocument(_ document: Document) throws {
    }
    
    public func startElement(_ element: Element, from document: Document) throws {
    }
    
    public func endElement(_ element: Element, from document: Document) throws {
    }
    
    public func textNode(_ textNode: TextNode, from document: Document) throws {
    }
    
    public func cdata(_ cdata: CDATANode, from document: Document) throws {
    }
    
    public func comment(_ comment: CommentNode, from document: Document) throws {
    }
    
    public func processingInstruction(_ instruction: ProcessingInstruction, from document: Document) throws {
    }

}

extension Element {
    internal func traverse(handler: DocumentHandler, document: Document) throws {
        try handler.startElement(self, from: document)
        for node in childNodes {
            switch node {
            case let element as Element:
                try element.traverse(handler: handler, document: document)
            case let textNode as TextNode:
                try handler.textNode(textNode, from: document)
            case let cdata as CDATANode:
                try handler.cdata(cdata, from: document)
            case let comment as CommentNode:
                try handler.comment(comment, from: document)
            default:
                break
            }
        }
        try handler.endElement(self, from: document)
    }
}
