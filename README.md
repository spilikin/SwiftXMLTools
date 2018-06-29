# XMLTools for Swift

![Swift 4.0+](https://img.shields.io/badge/Swift-4.0+-orange.svg)
![license](https://img.shields.io/github/license/mashape/apistatus.svg)

```XMLTools``` provides hight level API to work with XML written entirely in Swift. It provides API to parse and serialize XML, supports XPath-like access to XML-Infosets including the manipulation of structure and values and has full namespace support.

Since Apple only provides the low-level [XMLParser](https://developer.apple.com/documentation/foundation/xmlparser)
on all Platforms (only MacOS has the more advanced API), there are a lot of Open-Source Projects providing such APIs, most notably [SWXMLHash](https://github.com/drmohundro/SWXMLHash) and [SwiftyXMLParser](https://github.com/yahoojapan/SwiftyXMLParser).

The problem with all projects I've found on GitHUB is that they only support the simplest XML structures and queries. Most of them take inspiration from [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) and handle XML as JSON. There are two issues with that approach: 1) most of legacy XML Systems use rather complex XML structures with heavy use of namespaces; 2) if someone creates the new and simple protocols they use JSON anyway.

```XMLTools``` tries to close this gap and provides the "old school XML" using modern features of Swift programming language. It provides the following features:

* Full Namespaces and QNames support
* Lightweight DOM implementation
* XPath like access to XML node tree (including axes support)
* Subscript and Sequence support (like all other libraries)
* Datatypes Support (e.g. Text, Data, Int, Double, Decimal)
* Fully extensible to be used in specific use cases
* Serializing XML Document to Data
* XML creation and manipulation

# Quick Start

```swift
let parser = XMLTools.Parser()

let xml: XMLTools.Infoset
do {
    xml = try parser.parse(contentsOf: "https://ec.europa.eu/information_society/policy/esignature/trusted-list/tl-mp.xml")
} catch {
    print (error)
    return
}

xml.namespaceContext.declare(withNoPrefix: "http://uri.etsi.org/02231/v2#")
print(xml["TrustServiceStatusList", "SchemeInformation", "TSLType"].text)
// prints http://uri.etsi.org/TrstSvc/TrustedList/TSLType/EUlistofthelists
```

# Integration
## Swift Package Manager
```TODO```

# XPath-Like Selection API

Given the following Example XML based on [w3schools.com XPath Tutorial](https://www.w3schools.com/xml/xpath_syntax.asp)
```xml
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
```

## Parse String to XMLTools.Selection
```swift
let xmlString = """
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
let parser = XMLTools.Parser()

let xml: XMLTools.Selection
do {
    xml = try parser.parse(string: xmlString, using: .utf8)
} catch {
    print (error)
    return
}
```

## XPath equivalents for Swift XMLTools API


| Xpath | Swift |
|-------|-------|
| ```bookstore``` | ```xml["bookstore"]```<br/>```xml.select("bookstore")```|
| ```/bookstore``` | ```xml.selectDocument()["bookstore"]```<br/>```xml.selectDocument().select("bookstore")```|
| ```bookstore/book``` |```xml["bookstore", "book"]```<br/>```xml["bookstore"]["book"]```<br/>```xml.select("bookstore", "book")```<br/>```xml.select("bookstore").select("book")```|
| ```//book``` | ```xml.descendants("book")```|
| ```//@lang``` | ```xml.descendants().attr("lang")``` |
| ```/bookstore/book[1]``` |```xml["bookstore", "book", 0]```<br/>```xml["bookstore", "book"].item(0)```<br/>*note the 0-based index in Swift* |
| ```/bookstore/book[last()]``` | ```xml["bookstore", "book"].last()```|
| ```/bookstore/book[position()<3]```| ```xml["bookstore", "book"].select(byPosition: { $0 < 2 })```|
| ```//title[@lang]```| ```xml.descendants("title").select({ $0.attr("lang").text != "" })```|
| ```//title[@lang='en']```| ```xml.descendants("title").select({ $0.attr("lang").text == "en" })```|
| ```/bookstore/book[pages>300]```| ```xml["bookstore", "book"].select({ $0["pages"].intValue > 300 })```|
| ```/bookstore/book[price>35.00]```| ```xml["bookstore", "book"].select({ $0["price"].decimalValue > 35 })```|
| ```/bookstore/book[price>40.00]/title```| ```xml["bookstore", "book"].select({ $0["price"].doubleValue > 40 }).select("title")```|
| ```*```| ```xml.select()```|
| ```/bookstore/book/title/@*```| ```xml["bookstore", "book", "title"].attr()```|
| ```/bookstore/book/title[0]/node()```| ```xml["bookstore", "book", "title", 0].selectNode()```|
| ```/bookstore/*```| ```xml["bookstore"].select()```|
| ```//*```| ```xml.descendants()```|
| ```count(//book)```| ```xml.descendants("book").count```|
| ```bookstore/book[starts-with(title,'Harry Potter')]```| ```xml["bookstore", "book"].select({ $0["title"].text.starts(with: "Harry Potter") })```|

# Using namespaces
TODO

# Serializing XML
```swift
// Parse XML
let xmlLocation = "https://raw.githubusercontent.com/spilikin/SwiftXMLTools/master/Testfiles/xmldsig-core-schema.xsd"
let parser = XMLTools.Parser()
// tell the parser to preserve the namespace declarations (prefixes)
parser.options.preserveSourceNamespaceContexts = true
let xml: XMLTools.Infoset

do {
    xml = try parser.parse(contentsOf: xmlLocation)
} catch {
    print("\(error)")
    return
}

if let indentedData = xml.document().data(.indent) {
    print (String(data: indentedData, encoding:.utf8)! )
} else {
  print ("Cannot convert XML to Data")
}


```

# Creating XML from scratch
```swift
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
        .appendElement("title")
        .manipulate{ $0.text = book.title; $0.attr("lang", setValue: book.lang) }
        .parent()
        .appendElement("price").manipulate{ $0.decimalValue = book.price}.parent()
        .appendElement("pages").manipulate{ $0.intValue = book.pages }
}

let xmlData = built_xml.document().data(.indent,.omitXMLDeclaration)

print ( String(data: xmlData!, encoding: .utf8)! )
```
Should produce the following output:
```xml
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
```

# Developing the library

```XMLTools``` uses the Swift package manager
```
cd SwiftXMLTools
swift package generate-xcodeproj
swift build
swift test
```
