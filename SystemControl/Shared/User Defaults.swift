//
//  User Defaults.swift
//  BridgeScore
//
//  Created by Marc Shearer on 12/03/2022.
//

import Foundation

enum UserDefault: String, CaseIterable {
    case database
    case lastVersion
    case lastBuild
    case minVersion
    case minMessage
    case infoMessage
    
    public var defaultValue: Any? {
        switch self {
        case .database:
            return "unknown"
        case .lastVersion:
            return "0.0"
        case .lastBuild:
            return 0
        case .minVersion:
            return 0
        case .minMessage:
            return ""
        case .infoMessage:
            return ""
        }
    }
    
    public var name: String { "\(self)" }
       
    public func set(_ value: Any?) {
        UserDefault.set(value, forKey: self.name)
    }
    
    public var string: String {
        return UserDefault.string(forKey: self.name)
    }
    
    public var int: Int {
        return UserDefault.int(forKey: self.name)
    }
    
    public var float: Float {
        return UserDefault.float(forKey: self.name)
    }
    
    public var bool: Bool {
        return UserDefault.bool(forKey: self.name)
    }
    
    public var data: Data {
        return UserDefault.data(forKey: self.name)
    }
    
    public var array: [Any] {
        return UserDefault.array(forKey: self.name)
    }
    
    public var date: Date? {
        return UserDefault.date(forKey: self.name)
    }
    
    public var uuid: UUID? {
        return  UserDefault.uuid(forKey: self.name)
    }
    
    public var type: Type? {
        return UserDefault.type(forKey: self.name)
    }
    
    public static func set(_ value: Any?, forKey name: String) {
        if value == nil {
            MyApp.defaults.set(nil, forKey: name)
        } else if let array = value as? [Any] {
            MyApp.defaults.set(array, forKey: name)
        } else if let uuid = value as? UUID {
            MyApp.defaults.set(uuid.uuidString, forKey: name)
        } else if let type = value as? Type {
            MyApp.defaults.set("\(type.rawValue)", forKey: name)
        } else if let date = value as? Date {
            MyApp.defaults.set(date.toFullString(), forKey: name)
        } else {
            MyApp.defaults.set(value, forKey: name)
        }
    }
    
    public static func string(forKey name: String) -> String {
        return MyApp.defaults.string(forKey: name)!
    }
    
    public static func int(forKey name: String) -> Int {
        return MyApp.defaults.integer(forKey: name)
    }
    
    public static func float(forKey name: String) -> Float {
        return MyApp.defaults.float(forKey: name)
    }
    
    public static func bool(forKey name: String) -> Bool {
        return MyApp.defaults.bool(forKey: name)
    }
    
    public static func data(forKey name: String) -> Data {
        return MyApp.defaults.data(forKey: name)!
    }
    
    public static func array(forKey name: String) -> [Any] {
        return MyApp.defaults.array(forKey: name)!
    }
    
    public static func date(forKey name: String) -> Date? {
        let dateString = MyApp.defaults.string(forKey: name) ?? ""
        if dateString == "" {
            return nil
        } else {
            return Date(from: dateString, format: Date.fullDateFormat)
        }
    }
    
    public static func uuid(forKey name: String) -> UUID? {
        var result: UUID?
        if let uuid = UUID(uuidString: MyApp.defaults.string(forKey: name)!) {
            result = uuid
        }
        return result
    }
    
    public static func type(forKey name: String) -> Type? {
        return Type(rawValue: Int(MyApp.defaults.string(forKey: name) ?? "") ?? -1)
    }
    
}

enum FilterType: CaseIterable {
    case list
    case stats
    
    var string: String {
        return "\(self)"
    }
}

enum FilterUserDefault: String, CaseIterable {
    case filterPartners
    case filterLocations
    case filterDateFrom
    case filterDateTo
    case filterTypes
    case filterSearchText
    
    public var defaultValue: Any? {
        let empty: [Any?] = []
        switch self {
        case .filterPartners:
            return empty
        case .filterLocations:
            return empty
        case .filterDateFrom:
            return nil
        case .filterDateTo:
            return nil
        case .filterTypes:
            return empty
        case .filterSearchText:
            return ""
        }
    }
}
