import Foundation

extension Infoset {
    
    internal var DecimalFormatter:NumberFormatter {
        get {
            let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.decimalSeparator = "."
            formatter.thousandSeparator = ""
            formatter.maximumFractionDigits = 10
            print (formatter.maximumFractionDigits )
            formatter.numberStyle = .decimal
            return formatter
        }
    }

    
    public var intValue:Int? {
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

    public var doubleValue:Double? {
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
    
    public var decimalValue:Decimal? {
        get {
            return Decimal(string: text, locale: Locale(identifier: "en"))
        }
        set(newValue) {
            if let newValue = newValue {
                text = DecimalFormatter.string(from: newValue as NSDecimalNumber) ?? ""
            } else {
                text = ""
            }
        }
    }
    
    public var number:Decimal {
        get {
            return Decimal(string: text, locale: Locale(identifier: "en_US")) ?? 0
        }
        set(newValue) {
            text = DecimalFormatter.string(from: newValue as NSDecimalNumber) ?? "0"
        }
    }

}
