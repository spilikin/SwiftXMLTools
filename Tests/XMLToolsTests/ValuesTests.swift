//
//  ValuesTests.swift
//  XMLToolsTests
//
//  Created on 24.06.18
//

import XCTest
import XMLTools

class ValuesTests: XCTestCase {
    var xml: XMLTools.Infoset!

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
        let decimal: Decimal = 10000.09980
        xml["root"].number = decimal
        XCTAssertEqual(xml["root"].text, "10000.0998")
        XCTAssertEqual(xml["root"].number, decimal)
    }

    func testInt() {
        xml.document().appendElement("root")
        xml["root"].intValue = 99
        XCTAssertEqual("99", xml["root"].text)
        xml["root"].text = "98"
        XCTAssertEqual(98, xml["root"].intValue)
    }

    func testTextOptional() {
        xml.appendElement("root").attr("a", setValue: "value_a")
        xml["root"].appendElement("sub1").text = "subtext1"
        xml["root"].appendElement("sub2")

        XCTAssertEqual(xml["root"].attr("a").stringValue, "value_a")
        XCTAssertEqual(xml["root"].attr("no_such_element").stringValue, nil)

        XCTAssertEqual(xml["root", "sub1"].stringValue, "subtext1")
        XCTAssertEqual(xml["root", "sub2"].stringValue, nil)

    }
}
