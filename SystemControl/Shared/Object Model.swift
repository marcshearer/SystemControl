//
//  Object Model.swift
//  SystemControl
//
//  Created by Marc Shearer on 19/09/2024.
//

import CoreData

public class Model {
    public var entities: [Entity]
    
    public var model: NSManagedObjectModel {
        let result = NSManagedObjectModel()
        result.entities = entities.map{$0.entity}
        return result
    }
    
    init(_ entities: Entity...) {
        self.entities = entities
    }
}

@objcMembers public class ViewModel: NSObject, ViewModelProtocol {
    
    public var entity: Entity? = nil
    public var id: UUID { fatalError("Must be overridden") }
    @Published public var managedObject: NSManagedObject? = nil
    public var masterData: WrappedArray!
    
    public var newManagedObject: NSManagedObject {
        fatalError("Must be overridden")
    }
    
    public func save() {
        if self.isNew {
            insert(viewModel: self)
        } else {
            save(viewModel: self)
        }
    }

    public func beforeSave() {
    }
    
    public func insert() {
        insert(viewModel: self)
    }
    
    public func beforeInsert() {
    }

    public func remove() {
        remove(viewModel: self)
    }
    
    public func beforeRemove() {
    }
    
    public var exists: Bool {
        fatalError("Must be overridden")
    }
    
    public var isNew: Bool {
        return self.managedObject == nil
    }
    
    public func insert(viewModel: ViewModel) {
        assert(viewModel.isNew, "Cannot insert \(viewModel.entity?.name ?? "Entity") which already has a managed object")
        assert(!viewModel.exists, "\(viewModel.entity?.name ?? "Entity") already exists and cannot be created")
        viewModel.beforeInsert()
        let newMO = viewModel.newManagedObject
        CoreData.update {
            viewModel.managedObject = newMO
            viewModel.updateMO()
            
            viewModel.masterData.array.append(viewModel)
        }
    }
    
    public func remove(viewModel: ViewModel) {
        assert(!viewModel.isNew, "Cannot remove \(viewModel.entity?.name ?? "Entity") which doesn't already have a managed object")
        assert(viewModel.exists, "\(viewModel.entity?.name ?? "Entity") does not exist and cannot be deleted")
        viewModel.beforeRemove()
        CoreData.update {
            CoreData.context.delete(viewModel.managedObject!)
            if let index = viewModel.masterData.array.firstIndex(where: {$0 == viewModel}) {
                viewModel.masterData.array.remove(at: index)
            }
        }
    }
    
    public func save(viewModel: ViewModel) {
        assert(!viewModel.isNew, "Cannot save \(viewModel.entity?.name ?? "Entity") which doesn't already have a managed object")
        assert(viewModel.exists, "\(viewModel.entity?.name ?? "Entity") does not exist and cannot be updated")
        viewModel.beforeSave()
        if viewModel.changed {
            CoreData.update {
                viewModel.updateMO()
            }
            if let index = viewModel.masterData.array.firstIndex(where: {$0 == viewModel}) {
                viewModel.masterData.array[index] = viewModel
            }
        }
    }
    
    var changed: Bool {
        get {
            var result = false
            if let entity = entity {
                entity.forEach { (name, moName, type, _) in
                    if let managedObject = managedObject {
                        let moValue = managedObject.value(forKey: name)
                        let vmValue = self.value(forKey: name)
                        switch type {
                        case .int16, .int32, .int64:
                            if let vmValue = vmValue as? Int, let moValue = moValue as? Int {
                                if vmValue != moValue {
                                    result = true
                                }
                            }
                        case .string:
                            if let vmValue = vmValue as? String, let moValue = moValue as? String {
                                if vmValue != moValue {
                                    result = true
                                }
                            }
                        case .boolean:
                            if let vmValue = vmValue as? Bool, let moValue = moValue as? Bool {
                                if vmValue != moValue {
                                    result = true
                                }
                            }
                        case .date:
                            if let vmValue = vmValue as? Date, let moValue = moValue as? Date {
                                if vmValue != moValue {
                                    result = true
                                }
                            }
                        case .float:
                            if let vmValue = vmValue as? Float, let moValue = moValue as? Float {
                                if vmValue != moValue {
                                    result = true
                                }
                            }
                        case .uuid:
                            if let vmValue = vmValue as? UUID, let moValue = moValue as? UUID {
                                if vmValue != moValue {
                                    result = true
                                }
                            }
                        case .attributedString:
                            if let vmValue = vmValue as? AttributedString, let moValue = moValue as? AttributedString {
                                if vmValue != moValue {
                                    result = true
                                }
                            }
                        }
                    } else {
                        result = true
                    }
                }
            } else {
                result = true
            }
            return result
        }
    }
    
    func revert() {
        entity?.forEach { (name, moName, type, isOptional) in
            if let moValue = managedObject?.value(forKey: name) {
                self.setValue(moValue, forKey: name)
            } else {
                if isOptional {
                    self.setValue(nil, forKey: name)
                } else {
                    fatalError("Invalid value in view model")
                }
            }
        }
    }
    
    func copy(from: ViewModel) {
        entity?.forEach { (name, moName, type, isOptional) in
            if let fromValue = from.value(forKey: name) {
                self.setValue(fromValue, forKey: name)
            } else {
                if isOptional {
                    self.setValue(nil, forKey: name)
                } else {
                    fatalError("Invalid value in view model")
                }
            }
        }
        self.managedObject = from.managedObject
    }
    
    func updateMO() {
        entity?.forEach { (name, moName, type, isOptional) in
            if let managedObject = managedObject {
                if let vmValue = self.value(forKey: name) {
                    managedObject.setValue(vmValue, forKey: name)
                } else {
                    if isOptional {
                        managedObject.setValue(nil, forKey: name)
                    } else {
                        fatalError("Invalid value in view model")
                    }
                }
            }
        }
    }
}

public protocol ViewModelProtocol: Identifiable {
    var id: UUID {get}
    var newManagedObject: NSManagedObject {get}
}

public class Entity {
    public var name: String = ""
    public var className: String = ""
    public var attributes: [Attribute] = []
    public var entity: NSEntityDescription {
        get {
            let result = NSEntityDescription()
            result.name = name
            result.managedObjectClassName = className
            result.properties = attributes.map{$0.property}
            return result
        }
    }
        
    convenience init<T>(_ name: String, _ managedObject: T.Type, _ attributes: Attribute...) where T: ManagedObject {
        self.init()
        self.name = name
        self.className = NSStringFromClass(managedObject)
        self.attributes = attributes
    }
    
    
    func forEach(action: (String, String, EntityAttributeType, Bool)->()) {
        for attribute in attributes {
            action(attribute.name, attribute.moName, attribute.type, attribute.isOptional)
        }
    }
    
}

public class Attribute {
    var name: String = ""
    var moName: String = ""
    var type: EntityAttributeType = .string
    var isOptional: Bool = false
    var opaque: Bool = true
    
    public var property: NSAttributeDescription {
        get {
            let result = NSAttributeDescription()
            result.name = moName
            result.attributeType = type.nsAttributeType
            result.isOptional = isOptional
            if type == .attributedString {
                result.attributeValueClassName = "AttributedString"
                result.valueTransformerName = "AttributedStringToData"
            }
            return result
        }
    }
    
    convenience init(_ name: String, _ type: EntityAttributeType, isOptional: Bool = false, suffix: String = "") {
        self.init()
        self.name = name
        self.moName = name + suffix
        self.type = type
        self.isOptional = isOptional
        self.opaque = opaque
    }
}
    
public enum EntityAttributeType {
    case int16
    case int32
    case int64
    case string
    case boolean
    case date
    case float
    case uuid
    case attributedString
    
    var nsAttributeType: NSAttributeType {
        get {
            switch self {
            case .int16:            return .integer16AttributeType
            case .int32:            return .integer32AttributeType
            case .int64:            return .integer64AttributeType
            case .string:           return .stringAttributeType
            case .boolean:          return .booleanAttributeType
            case .date:             return .dateAttributeType
            case .float:            return .floatAttributeType
            case .uuid:             return .UUIDAttributeType
            case .attributedString: return .transformableAttributeType
            }
        }
    }
}

public class WrappedArray {
    public var array: [ViewModel] = []
}

@objc(AttributedStringToData)
class AttributedStringToData: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        let data = try! NSKeyedArchiver.archivedData(withRootObject: value as! NSAttributedString, requiringSecureCoding: false)
        return data
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        let dataValue = value as! Data
        let data = try! NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSAttributedString.self], from: dataValue)
        return data as! NSAttributedString
    }
}
