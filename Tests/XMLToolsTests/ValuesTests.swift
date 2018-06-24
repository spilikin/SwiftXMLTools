//
//  ValuesTests.swift
//  XMLToolsTests
//  
//  Created on 24.06.18
//

import XCTest
@testable import XMLTools

class ValuesTests: XCTestCase {
    var xml: XMLTools.Selection!
    
    override func setUp() {
        let doc = Document()
        xml = doc.select()
    }

    func testText() {
        let root = xml.document().appendElement("root")
        root.appendText("part1")
        root.appendText(" ")
        root.appendText("followed by part2")
        XCTAssertEqual(3, root.childNodes.count)
        XCTAssertEqual("part1 followed by part2", xml["root"].text)
        
        xml["root"].text = "completely different"
        XCTAssertEqual(1, root.childNodes.count)
        XCTAssertEqual("completely different", xml["root"].text)

    }

    func testDecimal() {
        xml.document().appendElement("root")
        xml["root"].decimalValue = 2.99
        XCTAssertEqual("2.99", xml["root"].text)
        xml["root"].text = "24.98"
        XCTAssertEqual(24.98, xml["root"].decimalValue)
    }

    func testDouble() {
        xml.document().appendElement("root")
        xml["root"].doubleValue = 24.99
        XCTAssertEqual("24.99", xml["root"].text)
        xml["root"].text = "24.98"
        XCTAssertEqual(24.98, xml["root"].doubleValue)
    }

    func testInt() {
        xml.document().appendElement("root")
        xml["root"].intValue = 99
        XCTAssertEqual("99", xml["root"].text)
        xml["root"].text = "98"
        XCTAssertEqual(98, xml["root"].intValue)
    }
}
