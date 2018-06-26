//
//  LOTLTests.swift
//  XMLToolsTests
//
//  Created on 23.06.18.
//

import XCTest
@testable import XMLTools

class LOTLTests: XCTestCase {

    let lotlURL = "https://ec.europa.eu/information_society/policy/esignature/trusted-list/tl-mp.xml"
    
    var lotl : Selection!
    
    override func setUp() {
        super.setUp()
        let parser = XMLTools.Parser()
        
        guard let parsed = try? parser.parse(contentsOf: lotlURL) else {
            XCTFail("Error: cant parse")
            return
        }
        lotl = parsed
    }
    
    
    func testNamespaces() {
        
        lotl.namespaceContext.declare(withNoPrefix: .tsl)
        XCTAssertEqual(1, lotl["TrustServiceStatusList"].count)
        XCTAssertEqual(NamespaceDeclaration.tsl.uri, lotl["TrustServiceStatusList"].name().namespaceURI)
        XCTAssertEqual("ID0001", lotl["TrustServiceStatusList"].attr("Id").text)
        
        XCTAssertEqual(1, lotl["TrustServiceStatusList"].attr(QName("Id")).count)
        XCTAssertEqual(0, lotl["TrustServiceStatusList"].attr(.qn("Id", xmlns: .tsl)).count)

        XCTAssertEqual("http://uri.etsi.org/TrstSvc/TrustedList/TSLType/EUlistofthelists", lotl["TrustServiceStatusList", "SchemeInformation", "TSLType"].text)
        
        XCTAssertEqual("application/vnd.etsi.tsl+xml", lotl["TrustServiceStatusList", "SchemeInformation", "PointersToOtherTSL", "OtherTSLPointer", 0].descendants(.qn("MimeType", xmlns: .tslx)).text)
        
        XCTAssertEqual(1, lotl.descendants(.qn("Signature", xmlns: .ds)).count)
        
        // SHA1 Digest must have exact 20 Bytes (160 Bits)
        XCTAssertEqual(20, lotl.descendants(.qn("CertDigest", xmlns: .xades)).select(.qn("DigestValue", xmlns: .ds)).data?.endIndex)
        XCTAssertEqual(20, lotl.descendants(.qn("CertDigest", xmlns: .xades)).select(XMLDSig.DigestValue).data?.endIndex)

        lotl.namespaceContext.declare("tsl", uri: "http://uri.etsi.org/02231/v2#")
        
        XCTAssertEqual(1, lotl["tsl:TrustServiceStatusList"].attr(QName("Id")).count)
        
        /*
         xmlns="http://uri.etsi.org/02231/v2#" tsl
         xmlns:ns2="http://www.w3.org/2000/09/xmldsig#" ds
         xmlns:ns3="http://uri.etsi.org/01903/v1.3.2#" xades
         xmlns:ns4="http://uri.etsi.org/02231/v2/additionaltypes#" tslx
         xmlns:ns5="http://uri.etsi.org/TrstSvc/SvcInfoExt/eSigDir-1999-93-EC-TrustedList/#" tns
         xmlns:ns6="http://uri.etsi.org/01903/v1.4.1#" xadesds
         */
    }
    
    func testNamespacesLang() {
    }
    

}

extension QName {
}

enum XMLDSig {
    static let DigestValue = QName.qn("DigestValue", xmlns: .ds)
}


extension NamespaceDeclaration {
    static let tsl = NamespaceDeclaration("tsl", uri: "http://uri.etsi.org/02231/v2#")
    static let tslx = NamespaceDeclaration("tslx", uri: "http://uri.etsi.org/02231/v2/additionaltypes#")
    static let xades = NamespaceDeclaration("xades", uri: "http://uri.etsi.org/01903/v1.3.2#")
}
