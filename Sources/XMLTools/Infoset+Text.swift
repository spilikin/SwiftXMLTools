import Foundation

extension Infoset {

    public var text: String {
        get {
            var result = ""
            for node in selectedNodes {
                if let val = nodeToText(node) {
                    result += val
                }
            }
            return result
        }
        set (newValue) {
            for node in selectedNodes {
                if let element = node as? XMLElement {
                    element.childNodes.removeAll()
                    element.appendText(newValue)
                }
            }
        }
    }

    public var stringValue: String? {
        var result: String?
        for node in selectedNodes {
            let val = nodeToText(node)
            if let val = val {
                if result == nil {
                    result = val
                } else {
                    result = result! + val
                }
            }
        }
        return result
    }
}
