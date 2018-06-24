import Foundation

enum ParserError: Error {
    case malformedURL(urlString:String)
    case contentNotAvailable(url: URL)
    case malformedString
    case parseError(lineNumber: Int, columnNumber: Int, cause: Error?)
}

struct Parser {
    func parse(data: Data) throws -> Selection {
        let delegate = ParserDelegate()
        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = true
        parser.delegate = delegate
        if (!parser.parse()) {
            throw ParserError.parseError(lineNumber: delegate.errorLineNumber, columnNumber: delegate.errorColumnNumber, cause: delegate.parseError)
        }
        
        return Selection(delegate.document)
    }
    
    func parse(string: String, using encoding:String.Encoding) throws -> Selection {
        guard let data = string.data(using: encoding) else {
            throw ParserError.malformedString
        }
        return try parse(data: data)
    }
    
    func parse(contentsOf url: URL) throws -> Selection {
        guard let data = try? Data(contentsOf: url) else {
            throw ParserError.contentNotAvailable(url: url)
        }
        return try parse(data: data)
    }
    
    func parse(contentsOf urlString: String) throws -> Selection {
        guard let url = URL(string: urlString) else {
            throw ParserError.malformedURL(urlString: urlString)
        }
        
        return try parse(contentsOf: url)
    }
    
}

fileprivate class ParserDelegate:NSObject, XMLParserDelegate {
    fileprivate var document: Document
    private var currentElement: Element?
    private var prefixMapping = [String:String]()
    fileprivate var parseError: Error?
    fileprivate var errorLineNumber = -1
    fileprivate var errorColumnNumber = -1
    
    override init() {
        document = Document()
        // https://www.w3.org/XML/1998/namespace
        prefixMapping["xml"] = "https://www.w3.org/XML/1998/namespace"
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if let parent = currentElement {
            currentElement = parent.appendElement(QName(elementName, uri: namespaceURI!))
        } else {
            currentElement = document.appendElement(QName(elementName, uri: namespaceURI!))
        }

        prefixMapping.forEach { (k,v) in currentElement?.prefixMapping[k] = v }
        prefixMapping.removeAll()
        
        for (name, value) in attributeDict {
            let qname: XMLTools.QName
            if name.range(of: ":") != nil {
                let tuple = name.components(separatedBy: ":")
                if let uri = resolveNamespaceURI(forPrefix: tuple[0]) {
                    qname = XMLTools.QName(tuple[1], uri: uri)
                } else {
                    qname = XMLTools.QName(name)
                }
            } else {
                qname = XMLTools.QName(name)
            }
            currentElement?.appendAttribute(qname, withValue: value)
        }
    }

    private func resolveNamespaceURI(forPrefix prefix: String ) -> String? {
        var element = currentElement
        while (element != nil) {
            if let uri = element?.prefixMapping[prefix] {
                return uri
            }
            element = element?.parentNode as? Element
        }
        return nil
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmed.count > 0 {
            currentElement?.appendText(trimmed)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let parent = currentElement?.parentNode as? Element {
            currentElement = parent
        } else {
            currentElement = nil
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
    }
    
    func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
        prefixMapping[prefix] = namespaceURI
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
        self.errorLineNumber = parser.lineNumber
        self.errorColumnNumber = parser.columnNumber
    }
}

