import Foundation

extension Infoset {

    func attr(_ name: String) -> Infoset {
        return attr(resolveQName(name, resolveDefaultNamespace: false))
    }
    
    func attr(_ qname: XMLTools.QName) -> Infoset {
        var matches = [Attribute]()
        for attr in attributeNodes() {
            if attr.name() == qname {
                matches.append(attr)
            }
        }
        return Infoset(matches, from: document())
    }
    
    internal func attributeNodes() -> [Attribute]{
        var attrs = [Attribute]()
        for node in selectedNodes {
            if let element = node as? Element {
                attrs.append(contentsOf: Array(element.attributes.values))
            }
        }
        return attrs
    }
    
    func attr() -> Infoset {
        
        return Infoset(attributeNodes(), from: document())
    }

}
