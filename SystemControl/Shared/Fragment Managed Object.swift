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
                             Attribute("firstChildId",          .UUIDAttributeType),
                             Attribute("document",              .stringAttributeType),
                             Attribute("edition",               .stringAttributeType),
                             Attribute("name",                  .stringAttributeType),
                             Attribute("content",               .stringAttributeType))

@objc(FragmentMO)
public class FragmentMO: NSManagedObject, ManagedObject, Identifiable {
    
    public static let entity = fragmentEntity
    
    @NSManaged public var fragmentId: UUID
    @NSManaged public var nextFragmentId: UUID
    @NSManaged public var firstChildId: UUID
    @NSManaged public var document: String
    @NSManaged public var edition: String
    @NSManaged public var sequence16: Int16
    @NSManaged public var name: String
    @NSManaged public var content: String
    
    public convenience init() {
        self.init()
        self.fragmentId = UUID()
    }
    
    @IntProperty<Int16>(key: "sequence16") var sequence: Int
}
