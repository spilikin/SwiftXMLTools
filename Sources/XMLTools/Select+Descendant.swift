import Foundation

extension Selection {
    func descendants(_ name: String) -> Selection {
        return descendants(resolveQName(name))
    }
    
    func descendants(_ qname: XMLTools.QName) -> Selection {
        var matches = [Node]()
        let selection = Selection([Node](), from: document())
        
        if selectedNodes.count == 0 {
            return Selection.EMPTY
        }
        
        for node in selectedNodes {
            if node.name() == qname {
                matches.append(node)
            }
        }
        selection.append(contentsOf: matches)
        let descendantSelection = selectNode().descendants(qname)
        selection.merge(with: descendantSelection)
        return selection
    }

    func descendants() -> Selection {
        var matches = [Node]()
        let selection = Selection([Node](), from: document())
        
        if selectedNodes.count == 0 {
            return Selection.EMPTY
        }
        
        for node in selectedNodes {
            if node as? XMLElement != nil {
                matches.append(node)
            }
        }
        selection.append(contentsOf: matches)
        let descendantSelection = selectNode().descendants()
        selection.merge(with: descendantSelection)
        return selection
    }
}
