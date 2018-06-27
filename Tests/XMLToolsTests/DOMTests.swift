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

    func testTraversal() {
        class Handler:DefaultDocumentHandler {
            
            var names = [QName]()
            
            override func startElement(_ element: Element, from document: Document) {
                names.append(element.name())
            }
            
        }
        
        let parser = XMLTools.Parser()
        
        let xml: XMLTools.Infoset
        do {
            xml = try parser.parse(contentsOf: "https://ec.europa.eu/information_society/policy/esignature/trusted-list/tl-mp.xml")
        } catch {
            print (error)
            XCTFail("\(error)")
            return
        }
        let handler = Handler()
        do {
            try xml.document().traverse(handler)
        } catch {
            XCTFail("\(error)")
        }
        XCTAssertTrue(handler.names.contains(QName("Name", uri: "http://uri.etsi.org/02231/v2#")))
    }
}
