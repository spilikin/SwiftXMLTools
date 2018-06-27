import Foundation

extension Infoset {
    
    var data:Data? {
        get {
            return Data(base64Encoded: text)
        }
        set (newValue) {
            if newValue != nil {
                text = newValue!.base64EncodedString()
            } else {
                text = ""
            }
        }
    }

}
