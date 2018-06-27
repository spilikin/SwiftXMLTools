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
        
        xml.namespaceContext.declare("tsl", uri: "http://uri.etsi.org/02231/v2#")
        print(xml["tsl:TrustServiceStatusList", "tsl:SchemeInformation", "tsl:TSLType"].text)
        // prints http://uri.etsi.org/TrstSvc/TrustedList/TSLType/EUlistofthelists

        xml.namespaceContext.declare(withNoPrefix: "http://uri.etsi.org/02231/v2#")
        print(xml["TrustServiceStatusList", "SchemeInformation", "TSLType"].text)
        // also prints http://uri.etsi.org/TrstSvc/TrustedList/TSLType/EUlistofthelists

        
    }

    static var allTests = [
        ("testExample1", testExample1),
        ("testExample2", testExample2),
    ]
}
