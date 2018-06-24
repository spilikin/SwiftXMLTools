import Foundation

extension Selection {

    func attr(_ name: String) -> Selection {
        return attr(resolveQName(name, resolveDefaultNamespace: false))
    }
    
    func attr(_ qname: XMLTools.QName) -> Selection {
        var matches = [Attribute]()
        for attr in attributeNodes() {
            if attr.name() == qname {
                matches.append(attr)
            }
        }
        return Selection(matches, from: document())
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
    
    func attr() -> Selection {
        
        return Selection(attributeNodes(), from: document())
    }

}
