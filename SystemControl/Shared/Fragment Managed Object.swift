//
//  Fragment Managed Object.swift
//  SystemControl
//
//  Created by Marc Shearer on 18/09/2024.
//

import CoreData

let fragmentEntity = Entity( "Fragment",
                             FragmentMO.self,
                             Attribute("fragmentId",            .UUIDAttributeType),
                             Attribute("nextFragmentId",        .UUIDAttributeType),
                             Attribute("firstChildFragmentId",  .UUIDAttributeType),
                             Attribute("document",              .stringAttributeType),
                             Attribute("edition",               .stringAttributeType),
                             Attribute("iterationRaw",          .integer32AttributeType),
                             Attribute("enumRaw",               .integer16AttributeType),
                             Attribute("name",                  .stringAttributeType),
                             Attribute("content",               .stringAttributeType))

@objc(FragmentMO)
public class FragmentMO: NSManagedObject, ManagedObject, Identifiable {
    
    public static let entity = fragmentEntity
    
    @NSManaged public var fragmentId: UUID
    @NSManaged public var nextFragmentId: UUID
    @NSManaged public var firstChildFragmentId: UUID
    @NSManaged public var document: String
    @NSManaged public var edition: String
    @NSManaged public var iterationRaw: Int32
    @NSManaged public var name: String
    @NSManaged public var content: String
    @NSManaged public var enumRaw: Int16
    @IntProperty<Int32, FragmentMO>(key: "iterationRaw") public var iteration: Int
    @EnumProperty<Test, FragmentMO>(key: "enumRaw") public var test: Test
    
    convenience init() {
        self.init(context: CoreData.context)
    }
}
public enum Test: Int {
    case x
    case y
}
