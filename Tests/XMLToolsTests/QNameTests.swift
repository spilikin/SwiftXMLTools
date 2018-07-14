//
//  QNameTests.swift
//  XMLToolsTests
//  
//  Created on 06.07.18
//

import XCTest
import XMLTools

class QNameTests: XCTestCase {

    let textXML = """
    <?xml version="1.0" encoding="utf-8"?>
    <root xmlns="urn:noprefix" xmlns:a="urn:a">
        <element1 name="a:name1"/>
        <element2 xmlns:b="urn:b" name="b:name2">
            <element3 name="b:name3"/>
        </element2>
    </root>
    """

    func testQNameValue() {
        let parser = XMLTools.Parser()
        do {
            let xml = try parser.parse(string: textXML)
            xml.namespaceContext.declare(withNoPrefix: "urn:noprefix")
            xml.namespaceContext.declare("a", uri: "urn:other_a")
            XCTAssertNotEqual(xml["root", "element1"].attr("name").qnameValue, QName("name1", uri: "urn:a"))
            XCTAssertEqual(xml["root", "element2"].attr("name").qnameValue, QName("name2", uri: "urn:b"))
            XCTAssertEqual(xml["root", "element2", "element3"].attr("name").qnameValue, QName("name3", uri: "urn:b"))
            xml.namespaceContext.remove(prefix: "a")
            XCTAssertEqual(xml["root", "element1"].attr("name").qnameValue, QName("name1", uri: "urn:a"))
            xml.namespaceContext.declare("a", uri: "urn:a")
            XCTAssertEqual(xml["root", "element1"].attr("name").qnameValue, QName("name1", uri: "urn:a"))
            XCTAssertTrue(xml["root"].attr("no_such_attribute").qnameValue == nil)
        } catch {
            XCTFail("\(error)")
            return
        }
    }

}
