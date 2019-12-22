import Foundation

extension Infoset {
    
    static internal var DecimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = 10
        formatter.numberStyle = .decimal
        return formatter
    }

    public var intValue: Int? {
        get {
            return Int(text)
        }
        set (newValue) {
            if let newValue = newValue {
                text = String(newValue)
            } else {
                text = ""
            }
        }
    }

    public var doubleValue: Double? {
        get {
            return Double(text)
        }
        set (newValue) {
            if let newValue = newValue {
                text = String(newValue)
            } else {
                text = ""
            }
        }
    }
    
    public var decimalValue: Decimal? {
        get {
            return Decimal(string: text, locale: Locale(identifier: "en"))
        }
        set(newValue) {
            if let newValue = newValue {
                text = Infoset.DecimalFormatter.string(from: newValue as NSDecimalNumber) ?? ""
            } else {
                text = ""
            }
        }
    }
    
    public var number: Decimal {
        get {
            return Decimal(string: text, locale: Locale(identifier: "en_US")) ?? 0
        }
        set(newValue) {
            text = Infoset.DecimalFormatter.string(from: newValue as NSDecimalNumber) ?? "0"
        }
    }

}
