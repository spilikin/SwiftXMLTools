import Foundation

extension Selection {

    var text:String {
        get {
            var result = ""
            for node in selectedNodes {
                result += nodeToText(node)
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
    
}
