import XCTest
@testable import XMLTools

final class XMLToolsTests: XCTestCase {
    func testExample1() {
        let xmlString =
        """
        <?xml version="1.0" encoding="UTF-8"?>

        <bookstore>

        <book>
        <title lang="en">Harry Potter: The Philosopher's Stone</title>
        <price>24.99</price>
        <pages>223</pages>
        </book>

        <book>
        <title lang="en">Harry Potter: The Chamber of Secrets</title>
        <price>29.99</price>
        <pages>251</pages>
        </book>

        <book>
        <title lang="en">Learning XML</title>
        <price>39.95</price>
        <pages>432</pages>
        </book>

        <book>
        <title lang="de" xml:lang="de">IT-Sicherheit: Konzepte - Verfahren - Protokolle</title>
        <price>69.95</price>
        <pages>932</pages>
        </book>

        </bookstore>
        """
        let parser = XMLTools.Parser()
        
        let xml: XMLTools.Infoset
        do {
            xml = try parser.parse(string: xmlString, using: .utf8)
        } catch {
            XCTFail("\(error)")
            return
        }
        
        for book in xml["bookstore", "book"] {
            print (book["title"].text)
        }
        
        // [24.99, 29.99, 39.95, 69.95]
        let pricesDecimal = xml.descendants("book").select("price").map( { $0.decimalValue } )
        print (pricesDecimal)

        // ["Harry Potter: The Philosopher's Stone", "Harry Potter: The Chamber of Secrets"]
        let potterBooks = xml["bookstore", "book", "title"].select({ $0.text.starts(with: "Harry Potter")}).map({$0.text})
        print (potterBooks)
    }

    func testExample2() {
        let parser = XMLTools.Parser()
        
        let xml: XMLTools.Infoset
        do {
            xml = try parser.parse(contentsOf: "https://ec.europa.eu/information_society/policy/esignature/trusted-list/tl-mp.xml")
        } catch {
            print (error)
            XCTFail("\(error)")
            return
        }
        
        xml.namespaceContext.declare(withNoPrefix: "http://uri.etsi.org/02231/v2#")
        print(xml["TrustServiceStatusList", "SchemeInformation", "TSLType"].text)
        // also prints http://uri.etsi.org/TrstSvc/TrustedList/TSLType/EUlistofthelists

        
    }
    
    func testExample3() {
        let parser = XMLTools.Parser()
        
        let xml: XMLTools.Infoset
        do {
            xml = try parser.parse(contentsOf: "https://ec.europa.eu/information_society/policy/esignature/trusted-list/tl-mp.xml")
        } catch {
            print (error)
            XCTFail("\(error)")
            return
        }
        
        // equivalent to xmlns:tsl="http://uri.etsi.org/02231/v2#"
        xml.namespaceContext.declare("tsl", uri: "http://uri.etsi.org/02231/v2#")
        print(xml["tsl:TrustServiceStatusList", "tsl:SchemeInformation", "tsl:TSLType"].text)
        // prints http://uri.etsi.org/TrstSvc/TrustedList/TSLType/EUlistofthelists
       
        xml.namespaceContext.remove(uri:"http://uri.etsi.org/02231/v2#")
        
        // equivalent to xmlns="http://uri.etsi.org/02231/v2#"
        xml.namespaceContext.declare(withNoPrefix: "http://uri.etsi.org/02231/v2#")

        // define the long XPath to reuse it later
        let xpathOtherTSLPointer = ["TrustServiceStatusList", "SchemeInformation", "PointersToOtherTSL", "OtherTSLPointer"]
        
        // how many TSLs are in Europe?
        print ("There are \(xml[xpathOtherTSLPointer].count) pointers to other TSLs")
        
        // select the german TSL
        let germanTSL = xml.select(xpathOtherTSLPointer).select {
            $0.select("AdditionalInformation", "OtherInformation", "SchemeTerritory").text.lowercased() == "de"
        }
        
        // another long XPath to be reused
        let xpathOperatorName = ["AdditionalInformation", "OtherInformation", "SchemeOperatorName", "Name"]
        
        // print some useful info, notite the usage of pre-defined .xml_lang constant from QName
        print ("German TSL is:")
        print(" - Operated by   : \(germanTSL[xpathOperatorName].select { $0.attr(.xml_lang).text == "en" } .text)")
        print("    in Deutsch   : \(germanTSL[xpathOperatorName].select { $0.attr(.xml_lang).text == "de" } .text)")
        print(" - TSL Located at: \( germanTSL["TSLLocation"].text )")

    }

    public func testExampleNamespaces() {
        let wsdl_source =
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <description xmlns="http://www.w3.org/ns/wsdl"
                     xmlns:tns="http://www.tmsws.com/wsdl20sample"
                     xmlns:whttp="http://schemas.xmlsoap.org/wsdl/http/"
                     xmlns:wsoap="http://schemas.xmlsoap.org/wsdl/soap/"
                     targetNamespace="http://www.tmsws.com/wsdl20sample">

        <documentation>
            This is a sample WSDL 2.0 document.
        </documentation>

        <!-- Abstract type -->
           <types>
              <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"
                        xmlns="http://www.tmsws.com/wsdl20sample"
                        targetNamespace="http://www.example.com/wsdl20sample">
                         
                 <xs:element name="request"> ... </xs:element>
                 <xs:element name="response"> ... </xs:element>
              </xs:schema>
           </types>

        <!-- Abstract interfaces -->
           <interface name="Interface1">
              <fault name="Error1" element="tns:response"/>
              <operation name="Get" pattern="http://www.w3.org/ns/wsdl/in-out">
                 <input messageLabel="In" element="tns:request"/>
                 <output messageLabel="Out" element="tns:response"/>
              </operation>
           </interface>

        <!-- Concrete Binding Over HTTP -->
           <binding name="HttpBinding" interface="tns:Interface1"
                    type="http://www.w3.org/ns/wsdl/http">
              <operation ref="tns:Get" whttp:method="GET"/>
           </binding>
           
        <!-- Concrete Binding with SOAP-->
           <binding name="SoapBinding" interface="tns:Interface1"
                    type="http://www.w3.org/ns/wsdl/soap"
                    wsoap:protocol="http://www.w3.org/2003/05/soap/bindings/HTTP/"
                    wsoap:mepDefault="http://www.w3.org/2003/05/soap/mep/request-response">
              <operation ref="tns:Get" />
           </binding>

        <!-- Web Service offering endpoints for both bindings-->
           <service name="Service1" interface="tns:Interface1">
              <endpoint name="HttpEndpoint"
                        binding="tns:HttpBinding"
                        address="http://www.example.com/rest/"/>
              <endpoint name="SoapEndpoint"
                        binding="tns:SoapBinding"
                        address="http://www.example.com/soap/"/>
           </service>
        </description>
        """
        let parser = XMLTools.Parser()
        
        let xml: XMLTools.Infoset
        do {
            xml = try parser.parse(string: wsdl_source)
        } catch {
            print (error)
            XCTFail("\(error)")
            return
        }

        // parsed this way, no namespaces are declared in the Infoset,
        // we need to access them by speicifying the URI directly
        print (xml[QName("description", uri: "http://www.w3.org/ns/wsdl"), QName("documentation", uri: "http://www.w3.org/ns/wsdl")].text)
        XCTAssertEqual(xml[QName("description", uri: "http://www.w3.org/ns/wsdl"), QName("documentation", uri: "http://www.w3.org/ns/wsdl")].text, "This is a sample WSDL 2.0 document.")

        // let's make it shorter, but still very bulky
        let wsdlURI = "http://www.w3.org/ns/wsdl"
        print (xml[QName("description", uri: wsdlURI), QName("documentation", uri: wsdlURI)].text)
        XCTAssertEqual(xml[QName("description", uri: wsdlURI), QName("documentation", uri: wsdlURI)].text, "This is a sample WSDL 2.0 document.")

        // define namespace context with prefix
        // please note, that the source has no prefix and it still works!
        // equivalent to xmlns:wsdl="http://www.w3.org/ns/wsdl"
        xml.namespaceContext.declare("wsdl", uri: "http://www.w3.org/ns/wsdl")
        print (xml["wsdl:description", "wsdl:documentation"].text)
        XCTAssertEqual(xml["wsdl:description", "wsdl:documentation"].text, "This is a sample WSDL 2.0 document.")

        // reset the namespace context
        xml.namespaceContext.remove(uri: "http://www.w3.org/ns/wsdl")

        // redefine the namespace without the prefix
        // equivalent to xmlns="http://www.w3.org/ns/wsdl"
        xml.namespaceContext.declare(withNoPrefix: "http://www.w3.org/ns/wsdl")
        print (xml["description", "documentation"].text)
        XCTAssertEqual(xml["description", "documentation"].text, "This is a sample WSDL 2.0 document.")

        // reset the namespace context
        xml.namespaceContext.remove(uri: "http://www.w3.org/ns/wsdl")

        // declare all namespaces we want to use
        xml.namespaceContext.declare(.wsdl).declare(.wsdl_soap).declare(.wsdl_http)
        xml.namespaceContext.declare("tns", uri: "http://www.tmsws.com/wsdl20sample")
        let http_binding = xml.descendants("wsdl:binding").select {
            $0.attr("name").text == "HttpBinding"
        }
        print (http_binding["wsdl:operation"].attr("whttp:method").text) // "GET"
        XCTAssertEqual(http_binding["wsdl:operation"].attr("whttp:method").text, "GET")

        let soap_binding = xml.descendants("wsdl:binding").select {
            $0.attr("name").text == "SoapBinding"
        }
        print (soap_binding.attr("wsoap:protocol").text) // "http://www.w3.org/2003/05/soap/bindings/HTTP/"
        XCTAssertEqual(soap_binding.attr("wsoap:protocol").text, "http://www.w3.org/2003/05/soap/bindings/HTTP/")
        
        let anotherParser = XMLTools.Parser()
        // tell the parser to preserve all namespace prefix declarations
        anotherParser.options.preserveSourceNamespaceContexts = true
        
        let another_xml: XMLTools.Infoset
        do {
            another_xml = try anotherParser.parse(string: wsdl_source)
        } catch {
            print (error)
            XCTFail("\(error)")
            return
        }
        
        print (another_xml["description"].name().namespaceURI) // "http://www.w3.org/ns/wsdl"
        XCTAssertEqual(another_xml["description"].name().namespaceURI, "http://www.w3.org/ns/wsdl")

    }
    
    static var allTests = [
        ("testExample1", testExample1),
        ("testExample2", testExample2),
        ("testExample3", testExample3),
    ]
}

extension NamespaceDeclaration {
    public static let wsdl = NamespaceDeclaration("wsdl", uri: "http://www.w3.org/ns/wsdl")
    public static let wsdl_soap = NamespaceDeclaration("wsoap", uri: "http://schemas.xmlsoap.org/wsdl/soap/")
    public static let wsdl_http = NamespaceDeclaration("whttp", uri: "http://schemas.xmlsoap.org/wsdl/http/")
}
