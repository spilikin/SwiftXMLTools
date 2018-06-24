struct NamespaceDeclaration {
    
    let prefix: String
    let uri: String
    
    init (_ prefix:String, uri: String) {
        self.prefix = prefix
        self.uri = uri
    }
}

extension NamespaceDeclaration {
    // See https://www.w3.org/XML/1998/namespace
    static let xml = NamespaceDeclaration("xml", uri:"https://www.w3.org/XML/1998/namespace")
    // XMLDSig
    static let ds = NamespaceDeclaration("ds", uri: "http://www.w3.org/2000/09/xmldsig#")

}

struct NamespaceContext {
    var ns = [String:String]()
    var defaultURI : String?

    @discardableResult
    mutating func prefix(_ declaration: NamespaceDeclaration) -> NamespaceContext {
        return prefix(declaration.prefix, uri:declaration.uri)
    }

    @discardableResult
    mutating func prefix(_ prefix: String, uri: String) -> NamespaceContext {
        self[prefix] = uri
        return self
    }

    @discardableResult
    mutating func noprefix(_ declaration: NamespaceDeclaration) -> NamespaceContext {
        return noprefix(declaration.uri)
    }

    @discardableResult
    mutating func noprefix(_ uri: String) -> NamespaceContext {
        defaultURI = uri
        self[""] = uri
        return self
    }
    
    subscript (prefix: String) -> String? {
        get {
            return ns[prefix]
        }
        mutating set (uri) {
            ns[prefix] = uri
        }
    }

}

struct QName: Hashable {
    
    let localName: String
    let namespaceURI: String
    
    init (_ name: String) {
        localName = name
        namespaceURI = ""
    }
    
    init (_ localName: String, uri namespaceURI: String) {
        self.localName = localName
        self.namespaceURI = namespaceURI
    }
    
    init (_ localName: String, xmlns declaration: NamespaceDeclaration) {
        self.init(localName, uri: declaration.uri)
    }
    
    static func == (lhs: QName, rhs: QName) -> Bool {
        return lhs.localName == rhs.localName && lhs.namespaceURI == rhs.namespaceURI
    }
    
    var hashValue: Int {
        return localName.hashValue ^ namespaceURI.hashValue
    }

    static func qn(_ localName: String, xmlns declaration: NamespaceDeclaration) -> QName {
        return QName(localName, xmlns: declaration)
    }
    
    static func qn(_ localName: String, uri namespaceURI: String) -> QName {
        return QName(localName, uri: namespaceURI)
    }
}

extension QName {
    // See https://www.w3.org/XML/1998/namespace
    // Designed for identifying the human language used in the scope of the element to which it's attached.
    static let xml_lang = QName("lang", uri: NamespaceDeclaration.xml.uri)
    // Designed to express whether or not the document's creator wishes white space to be considered as significant in the scope of the element to which it's attached.
    static let xml_space = QName("space", uri: NamespaceDeclaration.xml.uri)
    // The XML Base specification (Second edition) describes a facility, similar to that of HTML BASE, for defining base URIs for parts of XML documents. It defines a single attribute, xml:base, and describes in detail the procedure for its use in processing relative URI refeferences.
    static let xml_base = QName("base", uri: NamespaceDeclaration.xml.uri)
    // The xml:id specification defines a single attribute, xml:id, known to be of type ID independently of any DTD or schema.
    static let xml_id = QName("id", uri: NamespaceDeclaration.xml.uri)
}
