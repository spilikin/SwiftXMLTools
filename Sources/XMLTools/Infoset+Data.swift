import Foundation

extension Infoset {
    
    public var base64Data: Data? {
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
