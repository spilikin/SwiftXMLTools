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

}
