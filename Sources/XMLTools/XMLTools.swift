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
    // XMLSchema
    static let xs = NamespaceDeclaration("xs", uri: "http://www.w3.org/2001/XMLSchema")

    

}

class NamespaceContext {
    private var ns = [String:String]()

    init () {
        
    }
    
    static var defaultContext:NamespaceContext {
        get {
            let result = NamespaceContext()
            result.declare(.xml)
            return result
        }
    }
    
    init(copyOf context: NamespaceContext) {
        context.ns.forEach { (k,v) in ns[k] = v }
    }
    
    @discardableResult
    func declare(_ declaration: NamespaceDeclaration) -> NamespaceContext {
        return declare(declaration.prefix, uri:declaration.uri)
    }

    @discardableResult
    func declare(_ prefix: String, uri: String) -> NamespaceContext {
        self[prefix] = uri
        return self
    }

    @discardableResult
    func declare(withNoPrefix declaration: NamespaceDeclaration) -> NamespaceContext {
        return declare(withNoPrefix: declaration.uri)
    }

    @discardableResult
    func declare(withNoPrefix uri: String) -> NamespaceContext {
        defaultURI = uri
        return self
    }

    var defaultURI : String? {
        get {
            return self[""]
        }
        set(uri) {
            self[""] = uri
        }
    }

    subscript (prefix: String) -> String? {
        get {
            return ns[prefix]
        }
        set (uri) {
            ns[prefix] = uri
        }
    }

    func resolveURI(forPrefix prefix: String) -> String? {
        return self[prefix]
    }
    
    func resolvePrefix(forURI uri:String) -> String? {
        for (key, value) in ns {
            if value == uri {
                return key
            }
        }
        return nil
    }
    
    func allPrefixes() -> Set<String> {
        return Set(ns.keys)
    }

    func allURIs() -> Set<String> {
        return Set(ns.values)
    }
}

struct QName: Hashable, CustomStringConvertible {
    
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
    
    var description: String {
        get {
            if namespaceURI != "" {
                return "{\(namespaceURI)}\(localName)"
            } else if localName != "" {
                return localName
            } else {
                return "#anonymous"
            }
        }
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
