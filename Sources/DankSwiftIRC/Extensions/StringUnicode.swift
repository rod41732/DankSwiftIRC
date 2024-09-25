extension String {
    /// this extension properly split string by unicodeScalar. some notable case when regular split 
    /// doesn't work as expected "#pajlada 🏽" -> split() will not return 2-element array because <space> and <skin-tone>
    /// are treated as same character
    /// - Parameter separator: 
    /// - Returns: 
    public func split(byUnicodeScalar separator: UnicodeScalar, maxSplits: Int = Int.max) -> [String] {
        var parts = [String]()
        var part = "" 
        self.unicodeScalars.forEach { scalar in
            if parts.count < maxSplits && scalar == separator {
                parts.append(part)
                part = ""
            } else {
                part.unicodeScalars.append(scalar)
            }
        }
        parts.append(part)
        return parts
    }

    public var firstUnicodeScalar: UnicodeScalar? {
        return self.unicodeScalars.first
    }

    public func unicodeSubstring(from: Int, to: Int) -> String {
        let u = unicodeScalars
        let fromIndex = u.index(u.startIndex, offsetBy: from)
        let toIndex = u.index(fromIndex, offsetBy: to - from)
        return String(u[fromIndex ..< toIndex])
    }
    

    public mutating func dropFirstUnicodeScalar(count: Int = 1) {
        self.unicodeScalars.removeFirst(count)
    }
    
}