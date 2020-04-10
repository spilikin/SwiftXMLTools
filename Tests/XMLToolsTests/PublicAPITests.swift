//
//  PublicAPITests.swift
//  XMLToolsTests
//  
//  Created on 10.04.20
//

import XCTest
import XMLTools

class PublicAPITests: XCTestCase {

    func testAttributes() {
        let XML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <level1 xmlns:nsA="urn:dummy_A">
          <level1_1>
            <nsA:level1_1_1>Test1_1_1</nsA:level1_1_1>
            <nsA:level1_1_2>Test1_1_2</nsA:level1_1_2>
          </level1_1>
          <level1_2 xmlns:nsB="urn:dummy_B">
            <nsB:level1_2_1 attr1="attr1_value">Test1_2_1</nsB:level1_2_1>
            <nsB:level1_2_2 nsB:attr2="attr2_value">Test1_2_2</nsB:level1_2_2>
          </level1_2>
        </level1>
        """

        let parser = XMLTools.Parser()

        let xml: XMLTools.Infoset
        do {
            xml = try parser.parse(string: XML, using: .utf8)
        } catch {
            XCTFail("Error: cant parse \(error)")
            return
        }

        xml.namespaceContext.declare("custom_A", uri: "urn:dummy_A")
        xml.namespaceContext.declare("custom_B", uri: "urn:dummy_B")

        XCTAssertEqual(1, xml.descendants("custom_B:level1_2_2").attr().selectedNodes.count)

        XCTAssertEqual("Test1_2_1", xml["level1", "level1_2", "custom_B:level1_2_1"].text)

        XCTAssertEqual("attr2_value", xml["level1", "level1_2", "custom_B:level1_2_2"].attr("custom_B:attr2").text )

        if let element  = xml.descendants("custom_B:level1_2_2").selectedNodes.first as? Element {
            if let attribute = element.attributes[QName("attr2", uri: "urn:dummy_B")] {
                XCTAssertEqual("attr2_value", attribute.value)
                attribute.value = "attr2_value_changed"
                XCTAssertEqual("attr2_value_changed", xml["level1", "level1_2", "custom_B:level1_2_2"].attr("custom_B:attr2").text )
            } else {
                XCTFail("Expected attribute")
            }
        } else {
            XCTFail("Expected element")
        }
    }

}
