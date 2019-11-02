import Foundation

public enum ParserError: Error {
    case malformedURL (urlString: String)
    case contentNotAvailable (url: URL)
    case malformedString
    case parseError(lineNumber: Int, columnNumber: Int, cause: Error?)
}

public class Parser {
    public struct Options {
        // when set to true the parser will trim whitespaces and ommit the whitespace-only text nodes
        public var trimWhitespaces = true
        // when set to true the parser will preserve the namespace contexts of the source document (mapping prefix to uri)
        public var preserveSourceNamespaceContexts = false
    }

    public var options = Options()
    
    public init() {
    }

    public func parse(data: Data) throws -> Infoset {
        let delegate = ParserDelegate(options: options)
        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = true
        parser.delegate = delegate
        if !parser.parse() {
            throw ParserError.parseError(lineNumber: delegate.errorLineNumber, columnNumber: delegate.errorColumnNumber, cause: delegate.parseError)
        }
        
        return Infoset(delegate.document)
    }
    
    public func parse(string: String, using encoding: String.Encoding = .utf8) throws -> Infoset {
        guard let data = string.data(using: encoding) else {
            throw ParserError.malformedString
        }
        return try parse(data: data)
    }
    
    public func parse(contentsOf url: URL) throws -> Infoset {
        guard let data = try? Data(contentsOf: url) else {
            throw ParserError.contentNotAvailable(url: url)
        }
        return try parse(data: data)
    }
    
    public func parse(contentsOf urlString: String) throws -> Infoset {
        guard let url = URL(string: urlString) else {
            throw ParserError.malformedURL(urlString: urlString)
        }
        
        return try parse(contentsOf: url)
    }
    
}

private class ParserDelegate: NSObject, XMLParserDelegate {
    fileprivate var document: Document
    private var currentElement: Element?
    private var namespaceContext: NamespaceContext?
    fileprivate var parseError: Error?
    fileprivate var errorLineNumber = -1
    fileprivate var errorColumnNumber = -1
    private let options: Parser.Options
    
    init(options: Parser.Options) {
        self.options = options
        document = Document()
        namespaceContext = .defaultContext
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if let parent = currentElement {
            currentElement = parent.appendElement(QName(elementName, uri: namespaceURI!))
        } else {
            currentElement = document.appendElement(QName(elementName, uri: namespaceURI!))
        }

        if namespaceContext != nil {
            currentElement?.sourceNamespaceContext = NamespaceContext(copyOf: namespaceContext!)
            namespaceContext = nil
        }
        
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
        while element != nil {
            if let uri = element?.sourceNamespaceContext?[prefix] {
                return uri
            }
            element = element?.parentNode as? Element
        }
        return nil
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if options.trimWhitespaces {
            let trimmed = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if trimmed.count > 0 {
                currentElement?.appendText(trimmed)
            }
        } else {
            currentElement?.appendText(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let parent = currentElement?.parentNode as? Element {
            currentElement = parent
            if options.preserveSourceNamespaceContexts && currentElement?.sourceNamespaceContext != nil {
                currentElement?.namespaceContext = currentElement?.sourceNamespaceContext
            }
        } else {
            currentElement = nil
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
    }
    
    func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
        if namespaceContext == nil {
            // create empty namespace context
            namespaceContext = NamespaceContext()
        }
        namespaceContext?[prefix] = namespaceURI
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
        self.errorLineNumber = parser.lineNumber
        self.errorColumnNumber = parser.columnNumber
    }
}
