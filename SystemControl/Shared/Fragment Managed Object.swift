//
//  Fragment Managed Object.swift
//  SystemControl
//
//  Created by Marc Shearer on 18/09/2024.
//

import CoreData

let fragmentEntity = Entity( "Fragment",
                             FragmentMO.self,
                                Attribute("fragmentId",  .UUIDAttributeType),
                                Attribute("sequence16",  .integer32AttributeType, equivalent: "sequence"),
                                Attribute("name",        .stringAttributeType),
                                Attribute("content",     .stringAttributeType))

@objc(FragmentMO)
public class FragmentMO: NSManagedObject, ManagedObject, Identifiable {
    
    public static let entity = fragmentEntity
    
    @NSManaged public var fragmentId: UUID
    @NSManaged public var sequence16: Int16
    @NSManaged public var name: String
    @NSManaged public var content: String
    
    public convenience init() {
        self.init(context: CoreData.context)
        self.fragmentId = UUID()
    }
    
    @IntProperty(key: "sequence16") var sequence: Int
}

@propertyWrapper struct IntProperty<Int> {
    let key: String
    @available(*, unavailable) var wrappedValue: Int {
        get { fatalError("This wrapper only works on instance properties of classes") }
        set { fatalError("This wrapper only works on instance properties of classes") }
    }
    
    static subscript(
        _enclosingInstance instance: NSManagedObject,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<NSManagedObject, Int>,
        storage storageKeyPath: ReferenceWritableKeyPath<NSManagedObject, Self>
    ) -> Int {
        get {
            let propertyWrapper = instance[keyPath: storageKeyPath]
            let key = propertyWrapper.key
            return instance.value(forKey: key) as! Int
        }
        set {
            let propertyWrapper = instance[keyPath: storageKeyPath]
            let key = propertyWrapper.key
            instance.setValue(newValue as! Int16, forKey: key)
        }
    }
}

@propertyWrapper struct EnumProperty<E: RawRepresentable> where E.RawValue == Int {
    let key: String
    @available(*, unavailable) var wrappedValue: E {
        get { fatalError("This wrapper only works on instance properties of classes") }
        set { fatalError("This wrapper only works on instance properties of classes") }
    }
    
    static subscript(
        _enclosingInstance instance: NSManagedObject,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<NSManagedObject, E>,
        storage storageKeyPath: ReferenceWritableKeyPath<NSManagedObject, Self>
    ) -> E {
        get {
            let propertyWrapper = instance[keyPath: storageKeyPath]
            let key = propertyWrapper.key
            return E(rawValue: instance.value(forKey: key) as! Int)!
        }
        set {
            let propertyWrapper = instance[keyPath: storageKeyPath]
            let key = propertyWrapper.key
            instance.setValue(Int16(newValue.rawValue), forKey: key)
        }
    }
}
