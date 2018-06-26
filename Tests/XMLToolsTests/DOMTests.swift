//
//  DOMTests.swift
//  XMLToolsTests
//  
//  Created on 24.06.18
//

import XCTest
@testable import XMLTools

class DOMTests: XCTestCase {
    
    func testManualCreationAndEval() {
        let doc = XMLTools.Document()
        let root = doc.appendElement("root")
        root.appendAttribute("aaa", withValue: "bbb")
        root.appendAttribute("name1", withNamespace: "urn:test", andValue: "ccc")
        
        XCTAssertEqual("root", doc.documentElement?.name().localName)
        XCTAssertEqual("bbb", doc.documentElement?.attributes[QName("aaa")]?.value)
        XCTAssertEqual("ccc", doc.documentElement?.attributes[QName("name1", uri: "urn:test")]?.value)
    }

    func testDOMHandler() {
        class Handler:DocumentHandler {
            var names = [QName]()
            func startDocument(_ document: Document) {
            }
            
            func endDocument(_ document: Document) {
                
            }
            
            func startElement(_ element: Element, from document: Document) {
                names.append(element.name())
            }
            
            func endElement(_ element: Element, from document: Document) {
                
            }
            
            func textNode(_ textNode: TextNode, from document: Document) {
                
            }
            
            func cdata(_ cdata: CDATANode, from document: Document) {
                
            }
            
            func comment(_ comment: CommentNode, from document: Document) {
                
            }
            
        }
        
        let parser = XMLTools.Parser()
        
        let xml: XMLTools.Selection
        do {
            xml = try parser.parse(contentsOf: "https://ec.europa.eu/information_society/policy/esignature/trusted-list/tl-mp.xml")
        } catch {
            print (error)
            XCTFail("\(error)")
            return
        }
        let handler = Handler()
        xml.document().traverse(handler: handler)
        XCTAssertTrue(handler.names.contains(QName("Name", uri: "http://uri.etsi.org/02231/v2#")))
    }
}
