# XMLTools

![Swift 4.0+](https://img.shields.io/badge/Swift-4.0+-orange.svg)
![license](https://img.shields.io/github/license/mashape/apistatus.svg)

```XMLTools``` is yet another implementation of XML API written entirely in Swift. Since Apple only provides the low-level [```XMLParser```](https://developer.apple.com/documentation/foundation/xmlparser)
on all Platforms and only MacOS has the more advanced APIs, there are a lot of Open-Source Projects providing such APIs, most notably [SWXMLHash](https://github.com/drmohundro/SWXMLHash) and [SwiftyXMLParser](https://github.com/yahoojapan/SwiftyXMLParser).

The problem with all projects I've found on GitHUB is that they only support the simplest XML structures and queries. Most of them take inspiration from [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) and handle XML as JSON. There are two issues with that approach: 1) most of legacy XML Systems use rather complex XML structures with heavy use of namespaces; 2) if someone creates the new and simple protocols they use JSON anyway.

```XMLTools``` tries to close this gap and provides the "old school XML" using modern features of Swift programming language. It provides the following features:

* Full Namespaces and QNames support
* Lightweight DOM implementation
* XPath like access to XML node tree (including Axis support)
* Subscript and Sequence support (like all other libraries)
* Datatypes Support (Text, Data, Int, Double, Bool)
* Fully extensible to be used in specific use cases
* _Under Development_: XML creation and manipulation, Encoding XML node tree to Data

# Parsing
```swift
let parser = XMLTools.Parser()

let xml: XMLTools.Selection
do {
    xml = try parser.parse(contentsOf: "https://ec.europa.eu/information_society/policy/esignature/trusted-list/tl-mp.xml")
} catch {
    print (error)
    return
}

xml.namespaceContext.prefix("tsl", uri: "http://uri.etsi.org/02231/v2#")
print(xml["tsl:TrustServiceStatusList", "tsl:SchemeInformation", "tsl:TSLType"].text)
// prints http://uri.etsi.org/TrstSvc/TrustedList/TSLType/EUlistofthelists

xml.namespaceContext.noprefix("http://uri.etsi.org/02231/v2#")
print(xml["TrustServiceStatusList", "SchemeInformation", "TSLType"].text)
// also prints http://uri.etsi.org/TrstSvc/TrustedList/TSLType/EUlistofthelists

```

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
See XML above
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
| ``` ```| ``` ```|
| ``` ```| ``` ```<br/>``` ```|
