//
//  String Extensions.swift
// Bridge Score
//
//  Created by Marc Shearer on 01/02/2021.
//

import SwiftUI

extension String {
    
    func left(_ length: Int) -> String {
        return String(self.prefix(length))
    }
    
    func right(_ length: Int) -> String {
        return String(self.suffix(length))
    }
    
    func mid(_ from: Int, _ length: Int) -> String {
        return String(self.prefix(from+length).suffix(length))
    }
    
    func split(at: Character = ",") -> [String] {
        let substrings = self.split(separator: at).map(String.init)
        return substrings
    }
    
    
    var length: Int {
        get {
            return self.count
        }
    }
    
    func contains(_ contains: String, caseless: Bool = false) -> Bool {
        var string = self
        var contains = contains
        if caseless {
            string = string.lowercased()
            contains = contains.lowercased()
        }
        return string.range(of: contains) != nil
    }
    
    func position(_ contains: String, caseless: Bool = false, backwards: Bool = false) -> Int? {
        var string = self
        var contains = contains
        if caseless {
            string = string.lowercased()
            contains = contains.lowercased()
        }
        let range = string.range(of: contains, options: (backwards ? .backwards : []))
        if range == nil {
            return nil
        } else {
            return self.distance(from: self.startIndex, to: range!.lowerBound)
        }
    }
    
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    func rtrim() -> String {
        let trailingWhitespace = self.range(of: "\\s*$", options: .regularExpression)
        return self.replacingCharacters(in: trailingWhitespace!, with: "")
    }

    func ltrim() -> String {
        let leadingWhitespace = self.range(of: "^\\s*", options: .regularExpression)
        return self.replacingCharacters(in: leadingWhitespace!, with: "")
    }
    #if canImport(UIKit)
    func labelHeight(width: CGFloat? = nil, font: UIFont? = nil) -> CGFloat {
        return NSAttributedString(self).labelHeight(width: width, font: font)
    }

    func labelWidth(height: CGFloat? = nil, font: UIFont? = nil) -> CGFloat {
        return NSAttributedString(self).labelWidth(height: height, font: font)
    }
    #endif
    
    var splitCapitals: String {
        let value = NSMutableString(string: self)
        let pattern = "[A-Z]"
        let regex = try! NSRegularExpression(pattern: pattern)
        regex.replaceMatches(in: value, range: NSRange(location: 0, length: value.length), withTemplate: " $0")
        return (value as String).capitalized
    }
}

@propertyWrapper public final class OptionalStringBinding {
    public var wrappedValue: Binding<String>
    
    public init(_ optional: String?) {
        wrappedValue = Binding { optional ?? "" } set: { (_) in }
    }
}

@propertyWrapper public final class OptionalIntBinding {
    public var wrappedValue: Binding<Int>
    
    public init(_ optional: Int?) {
        wrappedValue = Binding { optional ?? 0 } set: { (_) in }
    }
}
