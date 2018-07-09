import XCTest
import Foundation
import XMLTools


class SelectTest: XCTestCase {
    let bookstore_xml = """
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
    <title lang="de">IT-Sicherheit: Konzepte - Verfahren - Protokolle</title>
    <price>69.95</price>
    <pages>932</pages>
    </book>

    </bookstore>
    """
    
    var xml : Infoset!
    
    override func setUp() {
        super.setUp()
        let parser = XMLTools.Parser()
        
        guard let parsed = try? parser.parse(string: bookstore_xml, using: .utf8) else {
            XCTFail("Error: cant parse")
            return
        }
        xml = parsed
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPaths() {
        // 1. bookstore
        XCTAssertEqual("bookstore", xml["bookstore"].name().localName)
        // 2. /bookstore
        XCTAssertEqual("bookstore", xml.selectDocument()["bookstore"].name().localName)
        // 3. bookstore/book
        XCTAssertEqual(4, xml["bookstore", "book"].count)
        XCTAssertEqual(4, xml["bookstore"]["book"].count)
        XCTAssertEqual(4, xml.select("bookstore", "book").count)
        XCTAssertEqual(4, xml.select("bookstore").select("book").count)
        // 4. //book
        XCTAssertEqual(4, xml.descendants("book").count)
        // 5. //@lang
        XCTAssertEqual(4, xml.descendants().attr("lang").count)
        // 6. /bookstore/book[1]
        XCTAssertEqual("Harry Potter: The Philosopher's Stone", xml["bookstore", "book", 0]["title"].text)
        XCTAssertEqual("Harry Potter: The Philosopher's Stone", xml["bookstore", "book"].item(0)["title"].text)
        // 7. /bookstore/book[last()]
        XCTAssertEqual("IT-Sicherheit: Konzepte - Verfahren - Protokolle", xml["bookstore", "book"].last()["title"].text)
        // 8. /bookstore/book[position()<3]
        XCTAssertEqual(2, xml["bookstore", "book"].select(byPosition: { $0 < 2 }).count )
        // 9. //title[@lang]
        XCTAssertEqual(4, xml.descendants("title").select({ $0.attr("lang").text != "" }).count )
        // 10. //title[@lang='en']
        XCTAssertEqual(3, xml.descendants("title").select({ $0.attr("lang").text == "en" }).count )
        // 11. /bookstore/book[pages>300]
        XCTAssertEqual(2, xml["bookstore", "book"].select({ $0["pages"].number > 300 }).count )
        // 11. /bookstore/book[price>35.00]
        XCTAssertEqual(2, xml["bookstore", "book"].select({ $0["price"].number > 35 }).count )
        // 12. /bookstore/book[price>40.00]/title
        XCTAssertEqual("IT-Sicherheit: Konzepte - Verfahren - Protokolle", xml["bookstore", "book"].select({ $0["price"].number > 40 }).select("title").text)
        XCTAssertEqual("IT-Sicherheit: Konzepte - Verfahren - Protokolle", xml["bookstore", "book"].select({ $0["price"].number > 40 })["title"].text)
        // 13. *
        XCTAssertEqual(1, xml.select().count)
        // 13. /bookstore/book/title/@*
        XCTAssertEqual(4, xml["bookstore", "book", "title"].attr().count)
        // 14. node()
        XCTAssertEqual(1, xml["bookstore", "book", "title", 0].selectNode().count) // must select the TextNode
        // 15. /bookstore/*
        XCTAssertEqual(4, xml["bookstore"].select().count)
        // 16. //*
        XCTAssertEqual(17, xml.descendants().count)
        // 17. count(//book)
        XCTAssertEqual(4, xml.descendants("book").count)
        // 18.
        XCTAssertEqual(["en", "en", "en", "de"], xml.descendants("book").map({ $0["title"].attr("lang").text}))
    }
    
    func testSequence() {
        
        let selection = xml["bookstore", "book"].select()
        
        // 4 boooks 3 elements each
        XCTAssertEqual(12, selection.count)
        
        for child in selection {
            XCTAssertTrue(["title", "price", "pages"].contains(child.name().localName), "Selected elements must be one of: title, price, pages")
        }
        
    }

    func testDescendants() {
    
        XCTAssertEqual(4, xml.descendants("price").count)
        // 100. Arrays
        XCTAssertEqual([24.99, 29.99, 39.95, 69.95], xml.descendants("price").map({$0.doubleValue}))
    }
 
    func testFilter() {
        // 200. bookstore/book[starts-with(title,'Harry Potter')]
        let potter = xml["bookstore", "book"].select({ $0["title"].text.starts(with: "Harry Potter") })
        XCTAssertTrue(potter.count == 2, "Expected 2 Harry Potter books")
        // 201. bookstore/book[@xml:lang="de"]
        //XCTAssertEqual("IT-Sicherheit: Konzepte - Verfahren - Protokolle", xml["bookstore", "book"].select({ $0.select("title").attr(.xml_lang).text == "de" })[0].select("title").text)
    }

}
