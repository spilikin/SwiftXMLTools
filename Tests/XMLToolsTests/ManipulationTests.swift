//
//  BuilderTests.swift
//  XMLToolsTests
//  
//  Created on 28.06.18
//

import XCTest
import XMLTools

class BuilderTests: XCTestCase {

    let expectedXmlSource =
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
    <title lang="de">IT-Sicherheit: Konzepte - Verfahren - Protokolle</title>
    <price>69.95</price>
    <pages>932</pages>
    </book>

    </bookstore>
    """

    
    func testBuildDocument() {
        

        struct Book {
            let title: String
            let lang: String
            let price: Decimal
            let pages: Int
        }
        let bookstore = [
            Book(title: "Harry Potter: The Philosopher's Stone", lang: "en", price: 24.99, pages: 223),
            Book(title: "Harry Potter: The Chamber of Secrets", lang: "en", price: 29.99, pages: 251),
            Book(title: "Learning XML", lang: "en", price: 39.95, pages: 432),
            Book(title: "IT-Sicherheit: Konzepte - Verfahren - Protokolle", lang: "de", price: 69.95, pages: 932),
        ]
        
        let built_xml = Document().select()
        
        built_xml.appendElement("bookstore")
        
        for book in bookstore {
            built_xml["bookstore"].appendElement("book")
                .appendElement("title").manipulate{ $0.text = book.title; $0.attr("lang", setValue: book.lang) } .parent()
                .appendElement("price").manipulate{ $0.decimalValue = book.price}.parent()
                .appendElement("pages").manipulate{ $0.intValue = book.pages }
        }
                
        let xmlData = built_xml.document().data(.indent,.omitXMLDeclaration)
        
        print ( String(data: xmlData!, encoding: .utf8)! )
        
        let parser = Parser()
        
        guard let parsed_xml = try? parser.parse(data: xmlData!) else {
            XCTFail("Unable to parse")
            return
        }
        
        // 1. bookstore
        XCTAssertEqual("bookstore", parsed_xml["bookstore"].name().localName)
        // 2. /bookstore
        XCTAssertEqual("bookstore", parsed_xml.selectDocument()["bookstore"].name().localName)
        // 3. bookstore/book
        XCTAssertEqual(4, parsed_xml["bookstore", "book"].count)
        XCTAssertEqual(4, parsed_xml["bookstore"]["book"].count)
        XCTAssertEqual(4, parsed_xml.select("bookstore", "book").count)
        XCTAssertEqual(4, parsed_xml.select("bookstore").select("book").count)
        // 4. //book
        XCTAssertEqual(4, parsed_xml.descendants("book").count)
        // 5. //@lang
        XCTAssertEqual(4, parsed_xml.descendants().attr("lang").count)
        // 6. /bookstore/book[1]
        XCTAssertEqual("Harry Potter: The Philosopher's Stone", parsed_xml["bookstore", "book", 0]["title"].text)
        XCTAssertEqual("Harry Potter: The Philosopher's Stone", parsed_xml["bookstore", "book"].item(0)["title"].text)
        // 7. /bookstore/book[last()]
        XCTAssertEqual("IT-Sicherheit: Konzepte - Verfahren - Protokolle", parsed_xml["bookstore", "book"].last()["title"].text)
        // 8. /bookstore/book[position()<3]
        XCTAssertEqual(2, parsed_xml["bookstore", "book"].select(byPosition: { $0 < 2 }).count )
        // 9. //title[@lang]
        XCTAssertEqual(4, parsed_xml.descendants("title").select({ $0.attr("lang").text != "" }).count )
        // 10. //title[@lang='en']
        XCTAssertEqual(3, parsed_xml.descendants("title").select({ $0.attr("lang").text == "en" }).count )
        // 11. /bookstore/book[pages>300]
        XCTAssertEqual(2, parsed_xml["bookstore", "book"].select({ $0["pages"].number > 300 }).count )
        // 11. /bookstore/book[price>35.00]
        XCTAssertEqual(2, parsed_xml["bookstore", "book"].select({ $0["price"].number > 35 }).count )
        // 12. /bookstore/book[price>40.00]/title
        XCTAssertEqual("IT-Sicherheit: Konzepte - Verfahren - Protokolle", parsed_xml["bookstore", "book"].select({ $0["price"].number > 40 }).select("title").text)
        XCTAssertEqual("IT-Sicherheit: Konzepte - Verfahren - Protokolle", parsed_xml["bookstore", "book"].select({ $0["price"].number > 40 })["title"].text)
        // 13. *
        XCTAssertEqual(1, parsed_xml.select().count)
        // 13. /bookstore/book/title/@*
        XCTAssertEqual(4, parsed_xml["bookstore", "book", "title"].attr().count)
        // 14. node()
        XCTAssertEqual(1, parsed_xml["bookstore", "book", "title", 0].selectNode().count) // must select the TextNode
        // 15. /bookstore/*
        XCTAssertEqual(4, parsed_xml["bookstore"].select().count)
        // 16. //*
        XCTAssertEqual(17, parsed_xml.descendants().count)
        // 17. count(//book)
        XCTAssertEqual(4, parsed_xml.descendants("book").count)
        // 18.
        XCTAssertEqual(["en", "en", "en", "de"], parsed_xml.descendants("book").map({ $0["title"].attr("lang").text}))

        
    }


    public func testManipulation() {
        let parser = Parser()
    
        let xml:Infoset
        do {
            xml = try parser.parse(string: expectedXmlSource)
        } catch {
            XCTFail("Unable to parse \(error)")
            return
        }
        
        XCTAssertEqual(4, xml.descendants("book").count)
        xml["bookstore"].appendElement("book")
        XCTAssertEqual(5, xml.descendants("book").count)

        XCTAssertTrue(xml["bookstore", "book"].select({$0["title"].text.starts(with: "Harry Potter")}).count == 2, "Expected 2 Harry Potter books")

        xml["bookstore", "book", 0, "title"].text = "I renamed this book!"

        XCTAssertTrue(xml["bookstore", "book"].select({$0["title"].text.starts(with: "Harry Potter")}).count == 1, "Expected 1 Harry Potter book after rename")
        
        // rename all books to Fahrenheit 451
        xml["bookstore", "book", "title"].text = "Fahrenheit 451"

        XCTAssertEqual(["Fahrenheit 451", "Fahrenheit 451", "Fahrenheit 451", "Fahrenheit 451"], xml["bookstore", "book", "title"].map{$0.text})

        XCTAssertEqual("de", xml["bookstore", "book", 3, "title"].attr("lang").text)
        xml["bookstore", "book", 3, "title"].attr("lang", setValue: "lv")
        XCTAssertEqual("lv", xml["bookstore", "book", 3, "title"].attr("lang").text)
        
        XCTAssertEqual("", xml["bookstore", "book", 3, "title"].attr("newattr").text)
        xml["bookstore", "book", 3, "title"].attr("newattr", setValue: "newval")
        XCTAssertEqual("newval", xml["bookstore", "book", 3, "title"].attr("newattr").text)

    }
    
}
