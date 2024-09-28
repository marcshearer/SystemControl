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

public class ViewModel: NSObject {
    
    public var entity: Entity? = nil
    @Published public var managedObject: NSManagedObject? = nil
    public var newManagedObject: NSManagedObject? = nil
    public var masterData: [ViewModel] = []

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
        assert(viewModel.exists, "\(viewModel.entity?.name ?? "Entity") already exists and cannot be created")
        viewModel.beforeInsert()
        CoreData.update {
            viewModel.managedObject = viewModel.newManagedObject
            viewModel.updateMO()
            
            self.masterData.append(viewModel)
        }
    }
    
    public func remove(viewModel: ViewModel) {
        assert(!viewModel.isNew, "Cannot remove \(viewModel.entity?.name ?? "Entity") which doesn't already have a managed object")
        assert(!viewModel.exists, "\(viewModel.entity?.name ?? "Entity") does not exist and cannot be deleted")
        viewModel.beforeRemove()
        CoreData.update {
            CoreData.context.delete(viewModel.managedObject!)
            if let index = viewModel.masterData.firstIndex(where: {$0 == viewModel}) {
                viewModel.masterData.remove(at: index)
            }
        }
    }
    
    public func save(viewModel: ViewModel) {
        assert(!viewModel.isNew, "Cannot save \(viewModel.entity?.name ?? "Entity") which doesn't already have a managed object")
        assert(!viewModel.exists, "\(viewModel.entity?.name ?? "Entity") does not exist and cannot be updated")
        viewModel.beforeSave()
        if viewModel.changed {
            CoreData.update {
                viewModel.updateMO()
            }
            if let index = viewModel.masterData.firstIndex(where: {$0 == viewModel}) {
                viewModel.masterData[index] = viewModel
            }
        }
    }
    var changed: Bool {
        get {
            var result = false
            if let entity = entity {
                entity.forEach { (name, type) in
                    if let managedObject = managedObject {
                        let moValue = managedObject.value(forKey: name)
                        let vmValue = self.value(forKey: name)
                        switch type {
                        case .int:
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
                        case .notSupported:
                            fatalError("Attribute type not supported")
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
        entity?.forEach { (name, type) in
            if let moValue = managedObject?.value(forKey: name) {
                self.setValue(moValue, forKey: name)
            } else {
                fatalError("Invalid value in view model")
            }
        }
    }
    
    func copy(from: ViewModel) {
        entity?.forEach { (name, type) in
            if let fromValue = from.value(forKey: name) {
                self.setValue(fromValue, forKey: name)
            } else {
                fatalError("Invalid value in source view model")
            }
        }
        self.managedObject = from.managedObject
    }
    
    func updateMO() {
        entity?.forEach { (name, type) in
            if let vmValue = self.value(forKey: name), let managedObject = managedObject {
                managedObject.setValue(vmValue, forKey: name)
            } else {
                fatalError("Invalid value in source view model")
            }
        }
    }
    
    
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
    
    
    func forEach(action: (String, EntityAttributeType)->()) {
        for attribute in attributes {
            action(attribute.equivalent ?? attribute.name, attribute.equivalentType)
        }
    }
    
}

public class Attribute {
    var name: String = ""
    var attributeType: NSAttributeType = .stringAttributeType
    var isOptional: Bool = false
    var equivalent: String? = nil
    var equivalentType: EntityAttributeType = .notSupported
    
    public var property: NSAttributeDescription {
        get {
            let result = NSAttributeDescription()
            result.name = name
            result.attributeType = attributeType
            result.isOptional = isOptional
            return result
        }
    }
    
    convenience init(_ name: String, _ type: NSAttributeType, isOptional: Bool = false, equivalent: String? = nil, equivalentType: EntityAttributeType? = nil) {
        self.init()
        self.name = name
        self.attributeType = type
        self.isOptional = isOptional
        self.equivalent = equivalent
        self.equivalentType = equivalentType ?? EntityAttributeType(type: type)
    }
}
    
public enum EntityAttributeType {
    case int
    case string
    case boolean
    case date
    case float
    case uuid
    case notSupported
    
    init(type: NSAttributeType) {
        switch type {
        case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType:
            self = .int
        case .stringAttributeType:
            self = .string
        case .booleanAttributeType:
            self = .boolean
        case .dateAttributeType:
            self = .date
        case .floatAttributeType:
            self = .float
        case .UUIDAttributeType:
            self = .uuid
        default:
            self = .notSupported
        }
    }
}

@propertyWrapper public struct IntProperty<RowType: NSManagedObject, IntType: BinaryInteger> {
    public let key: String
    @available(*, unavailable) public var wrappedValue: Int {
        get { fatalError("This wrapper only works on instance properties of classes") }
        set { fatalError("This wrapper only works on instance properties of classes") }
    }
    
    public static subscript(
        _enclosingInstance instance: RowType,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<RowType, Int>,
        storage storageKeyPath: ReferenceWritableKeyPath<RowType, Self>
    ) -> Int {
        get {
            let propertyWrapper = instance[keyPath: storageKeyPath]
            let key = propertyWrapper.key 
            return instance.value(forKey: key) as! Int
        }
        set {
            let propertyWrapper = instance[keyPath: storageKeyPath]
            let key = propertyWrapper.key
            instance.setValue(Int16(newValue), forKey: key)
        }
    }
}

@propertyWrapper public struct EnumProperty<RowType: NSManagedObject, EnumType: RawRepresentable> where EnumType.RawValue == Int {
    public let key: String
    @available(*, unavailable) public var wrappedValue: EnumType {
        get { fatalError("This wrapper only works on instance properties of classes") }
        set { fatalError("This wrapper only works on instance properties of classes") }
    }
    
    public static subscript(
        _enclosingInstance instance: RowType,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<RowType, EnumType>,
        storage storageKeyPath: ReferenceWritableKeyPath<RowType, Self>
    ) -> EnumType {
        get {
            let propertyWrapper = instance[keyPath: storageKeyPath]
            let key = propertyWrapper.key
            return EnumType(rawValue: instance.value(forKey: key) as! Int)!
        }
        set {
            let propertyWrapper = instance[keyPath: storageKeyPath]
            let key = propertyWrapper.key
            instance.setValue(Int16(newValue.rawValue), forKey: key)
        }
    }
}
