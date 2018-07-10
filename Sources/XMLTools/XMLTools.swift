public struct NamespaceDeclaration {
    
    public let prefix: String
    public let uri: String
    
    public init (_ prefix:String, uri: String) {
        self.prefix = prefix
        self.uri = uri
    }
}

extension NamespaceDeclaration {
    // See https://www.w3.org/XML/1998/namespace
    public static let xml = NamespaceDeclaration("xml", uri:"https://www.w3.org/XML/1998/namespace")
    // XMLDSig
    public static let ds = NamespaceDeclaration("ds", uri: "http://www.w3.org/2000/09/xmldsig#")
    // XMLSchema
    public static let xs = NamespaceDeclaration("xs", uri: "http://www.w3.org/2001/XMLSchema")
    // XML Schema instance
    public static let xsi = NamespaceDeclaration("xsi", uri: "http://www.w3.org/2001/XMLSchema-instance")
}

public class NamespaceContext {
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
        context.ns.forEach { (key,value) in ns[key] = value }
    }
    
    @discardableResult
    public func declare(_ declaration: NamespaceDeclaration) -> NamespaceContext {
        return declare(declaration.prefix, uri:declaration.uri)
    }

    @discardableResult
    public func declare(_ prefix: String, uri: String) -> NamespaceContext {
        self[prefix] = uri
        return self
    }

    @discardableResult
    public func declare(withNoPrefix declaration: NamespaceDeclaration) -> NamespaceContext {
        return declare(withNoPrefix: declaration.uri)
    }

    @discardableResult
    public func declare(withNoPrefix uri: String) -> NamespaceContext {
        defaultURI = uri
        return self
    }

    public var defaultURI : String? {
        get {
            return self[""]
        }
        set(uri) {
            self[""] = uri
        }
    }

    public subscript (prefix: String) -> String? {
        get {
            return ns[prefix]
        }
        set (uri) {
            ns[prefix] = uri
        }
    }

    public func resolveURI(forPrefix prefix: String) -> String? {
        return self[prefix]
    }
    
    public func resolvePrefix(forURI uri:String) -> String? {
        for (key, value) in ns {
            if value == uri {
                return key
            }
        }
        return nil
    }
    
    public func allPrefixes() -> Set<String> {
        return Set(ns.keys)
    }

    public func allURIs() -> Set<String> {
        return Set(ns.values)
    }
    
    public func remove(prefix:String) {
        ns.removeValue(forKey: prefix)
    }

    public func remove(uri:String) {
        ns = ns.filter { $1 != uri }
    }

}

public struct QName: Hashable, CustomStringConvertible {
    
    
    public let localName: String
    public let namespaceURI: String
    
    public init (_ name: String) {
        localName = name
        namespaceURI = ""
    }
    
    public init (_ localName: String, uri namespaceURI: String) {
        self.localName = localName
        self.namespaceURI = namespaceURI
    }
    
    public init (_ localName: String, xmlns declaration: NamespaceDeclaration) {
        self.init(localName, uri: declaration.uri)
    }
    
    public static func == (lhs: QName, rhs: QName) -> Bool {
        return lhs.localName == rhs.localName && lhs.namespaceURI == rhs.namespaceURI
    }
    
    public var hashValue: Int {
        return localName.hashValue ^ namespaceURI.hashValue
    }

    public static func qn(_ localName: String, xmlns declaration: NamespaceDeclaration) -> QName {
        return QName(localName, xmlns: declaration)
    }
    
    public static func qn(_ localName: String, uri namespaceURI: String) -> QName {
        return QName(localName, uri: namespaceURI)
    }
    
    public var description: String {
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
    /// See https://www.w3.org/XML/1998/namespace
    /// Designed for identifying the human language used in the scope of the element to which it's attached.
    public static let XmlLang = QName("lang", uri: NamespaceDeclaration.xml.uri)
    /// Designed to express whether or not the document's creator wishes white space to be considered as
    /// significant in the scope of the element to which it's attached.
    public static let XmlSpace = QName("space", uri: NamespaceDeclaration.xml.uri)
    /// The XML Base specification (Second edition) describes a facility, similar to that of HTML BASE,
    /// for defining base URIs for parts of XML documents. It defines a single attribute, xml:base,
    /// and describes in detail the procedure for its use in processing relative URI refeferences.
    public static let XmlBase = QName("base", uri: NamespaceDeclaration.xml.uri)
    /// The xml:id specification defines a single attribute, xml:id,
    /// known to be of type ID independently of any DTD or schema.
    public static let XmlId = QName("id", uri: NamespaceDeclaration.xml.uri)
}
