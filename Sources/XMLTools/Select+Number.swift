import Foundation

extension Selection {
    
    var intValue:Int {
        get {
            return Int(text) ?? 0
        }
        set (newValue) {
            text = String(newValue)
        }
    }

    var doubleValue:Double {
        get {
            return Double(text) ?? 0.0
        }
        set (newValue) {
            text = String(newValue)
        }
    }
    
    var decimalValue:Decimal {
        get {
            return Decimal(string: text, locale: Locale(identifier: "en")) ?? 0
        }
        set(newValue) {
            text = newValue.description
        }
    }
}
