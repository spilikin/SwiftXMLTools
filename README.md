# XMLTools for Swift

![Swift 4.0+](https://img.shields.io/badge/Swift-4.0+-orange.svg)
![license](https://img.shields.io/github/license/mashape/apistatus.svg)

``XMLTools`` is a set APIs to parse, evaluate, manipulate and serialize complex XML structures. It is written written entirely in Swift programming language and designed to work on  all platforms supporting Swift (e.g. macOS, iOS).

``XMLTOOLS`` provides the following features:

* Full Namespaces and QNames support
* Lightweight DOM implementation
* XPath like access to XML node tree (including axes support)
* Subscript and Sequence support (like all other libraries)
* Datatypes Support (e.g. Text, Data, Int, Double, Decimal)
* Serializing XML Document to Data
* XML creation and manipulation
* Fully extensible to be used in specific use cases (e.g. SOAP)

## Motivation

Since Apple only provides the low-level [XMLParser](https://developer.apple.com/documentation/foundation/xmlparser)
on all it's Platforms (with exception of macOS, which has high level XML API), there are a lot of Open-Source Projects providing such APIs, most notably [SWXMLHash](https://github.com/drmohundro/SWXMLHash) and [SwiftyXMLParser](https://github.com/yahoojapan/SwiftyXMLParser).

The problem with all projects I've found on GitHUB is that they only support the simplest XML structures and queries. Most of them take inspiration from [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) and handle XML as JSON. There are two issues with that approach: 1) most of legacy XML Systems use rather complex XML structures with heavy use of namespaces; 2) if someone creates the new and simple protocols they use JSON anyway.

``XMLTools`` tries to close this gap and provides the "old school XML" using modern features of Swift programming language.

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

TODO

# XPath-Like Selection API

The following Example XML is based on [w3schools.com XPath Tutorial](https://www.w3schools.com/xml/xpath_syntax.asp)
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

## Parse String to Infoset
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

let xml: XMLTools.Infoset
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

Consider the example from [Wikipedia article about WSDL](https://en.wikipedia.org/wiki/Web_Services_Description_Language)
```swift
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

```

Since we didn't specify any options when creating the "XMLTools.Parser" there are no namespace declarations in the current Infoset and every element must be accessed by using the qualified names:
```swift
print (xml[QName("description", uri: "http://www.w3.org/ns/wsdl"), QName("documentation", uri: "http://www.w3.org/ns/wsdl")].text)
```

Event if we make it shorter it's still not very easy to read:
```swift
let wsdlURI = "http://www.w3.org/ns/wsdl"
print (xml[QName("description", uri: wsdlURI), QName("documentation", uri: wsdlURI)].text)
```

The better way is to declare the namespace. Please note, that even if the source XML has no prefix defined we still should access the elements and attributes by using the prefix defined here. This way the code is independent of the source namespace prefixes, especially when sources are generated and use cryptic prefixes like ``ns0``:
```swift
// equivalent to xmlns:wsdl="http://www.w3.org/ns/wsdl"
xml.namespaceContext.declare("wsdl", uri: "http://www.w3.org/ns/wsdl")
print (xml["wsdl:description", "wsdl:documentation"].text)
```

If we want to access WSDL elements without the prefix we can do it this way:
```swift
// equivalent to xmlns="http://www.w3.org/ns/wsdl"
xml.namespaceContext.declare(withNoPrefix: "http://www.w3.org/ns/wsdl")
print (xml["description", "documentation"].text)
```

Here is a more complex example demonstrating the extensibility of ```XMLTools``` API:

```swift
// somewhere on file level
extension NamespaceDeclaration {
    public static let wsdl = NamespaceDeclaration("wsdl", uri: "http://www.w3.org/ns/wsdl")
    public static let wsdl_soap = NamespaceDeclaration("wsoap", uri: "http://schemas.xmlsoap.org/wsdl/soap/")
    public static let wsdl_http = NamespaceDeclaration("whttp", uri: "http://schemas.xmlsoap.org/wsdl/http/")
}
```

```swift
// declare the namespaces we want to use
xml.namespaceContext.declare(.wsdl).declare(.wsdl_soap).declare(.wsdl_http)
let http_binding = xml.descendants("wsdl:binding").select {
    $0.attr("name").text == "HttpBinding"
}
print (http_binding["wsdl:operation"].attr("whttp:method").text) // "GET"

let soap_binding = xml.descendants("wsdl:binding").select {
    $0.attr("name").text == "SoapBinding"
}
print (soap_binding.attr("wsoap:protocol").text) // "http://www.w3.org/2003/05/soap/bindings/HTTP/"

```

And finally we can just be lazy and tell the parser to preserve all namespace declarations exactly as they appear in the XML source
```swift
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
```



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

# Developing XMLTools

``XMLTools`` uses the Swift package manager

```
cd SwiftXMLTools
swift package generate-xcodeproj
swift build
swift test
```
