//
//  SerializerTests.swift
//  XMLToolsTests
//  
//  Created on 26.06.18
//

import XCTest
import XMLTools

class SerializerTests: XCTestCase {

    func testSerializeWithIndentAndParse() {
        let xmlLocation = "https://raw.githubusercontent.com/spilikin/SwiftXMLTools/master/Testfiles/xmldsig-core-schema.xsd"
        let parser = XMLTools.Parser()
        parser.options.preserveSourceNamespaceContexts = true
        let xml: XMLTools.Infoset
        
        do {
            xml = try parser.parse(contentsOf: xmlLocation)
        } catch {
            XCTFail("\(error)")
            return
        }

        //xml.namespaceContext.declare(.xs)
        if let indentedData = xml.document().data(.indent) {
            print (String(data: indentedData, encoding: .utf8)! )

            do {
                let reparsed = try parser.parse(data: indentedData)
                reparsed.namespaceContext.declare(.xsd)
                XCTAssertEqual(xml.descendants().count, reparsed.descendants().count)
            } catch {
                XCTFail("\(error)")
                return
            }

        } else {
            XCTFail("Cannon convert XML to Data")
        }
    }

    func testNamespaceSerializeAndParser() {
        let parser = XMLTools.Parser()
        parser.options.preserveSourceNamespaceContexts = true
        let xml: XMLTools.Infoset

        do {
            xml = try parser.parse(string: NamespaceTests.namespaceXML, using: .utf8)
        } catch {
            XCTFail("\(error)")
            return
        }

        if let indentedData = xml.document().data(.indent) {
            print (String(data: indentedData, encoding: .utf8)! )

            do {
                let reparsed = try parser.parse(data: indentedData)
                XCTAssertEqual(xml.descendants().count, reparsed.descendants().count)

                XCTAssertEqual("Test1_1_1", reparsed[QName("level1")][QName("level1_1")][QName("level1_1_1", uri: "urn:dummy_A")].text)
                
                XCTAssertEqual("Test1_1_1Test1_1_2", reparsed["level1", "level1_1"].text)
                XCTAssertEqual("Test1_2_1Test1_2_2", reparsed["level1", "level1_2"].text)
                
                reparsed.namespaceContext.declare("custom_A", uri: "urn:dummy_A")
                reparsed.namespaceContext.declare("custom_A_2", uri: "urn:dummy_A")
                XCTAssertEqual("Test1_1_1", reparsed["level1", "level1_1", "custom_A:level1_1_1"].text)
                XCTAssertEqual("Test1_1_1", reparsed["level1", "level1_1", "custom_A_2:level1_1_1"].text)
                
                reparsed.namespaceContext.declare("custom_B", uri: "urn:dummy_B")
                XCTAssertEqual("Test1_2_1", reparsed["level1", "level1_2", "custom_B:level1_2_1"].text)
                
                XCTAssertEqual("attr2_value", reparsed["level1", "level1_2", "custom_B:level1_2_2"].attr("custom_B:attr2").text )
            } catch {
                XCTFail("\(error)")
                return
            }
            
        } else {
            XCTFail("Cannon convert XML to Data")
        }

    }

}
