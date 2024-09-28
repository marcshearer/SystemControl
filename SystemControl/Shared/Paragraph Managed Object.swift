//
//  Paragraph Managed Object.swift
//  SystemControl
//
//  Created by Marc Shearer on 18/09/2024.
//

import CoreData

let paragraphEntity = Entity( "Paragraph",
                             ParagraphMO.self,
                             Attribute("paragraphId",            .UUIDAttributeType),
                             Attribute("nextParagraphId",        .UUIDAttributeType),
                             Attribute("firstChildParagraphId",  .UUIDAttributeType),
                             Attribute("document",              .stringAttributeType),
                             Attribute("edition",               .stringAttributeType),
                             Attribute("iterationRaw",          .integer32AttributeType),
                             Attribute("enumRaw",               .integer16AttributeType),
                             Attribute("name",                  .stringAttributeType),
                             Attribute("content",               .stringAttributeType))

@objc(ParagraphMO)
public class ParagraphMO: NSManagedObject, ManagedObject, Identifiable {
    
    public static let entity = paragraphEntity
    
    @NSManaged public var paragraphId: UUID
    @NSManaged public var nextParagraphId: UUID
    @NSManaged public var firstChildParagraphId: UUID
    @NSManaged public var document: String
    @NSManaged public var edition: String
    @NSManaged public var iterationRaw: Int32   ; @IntProperty(\ParagraphMO.iterationRaw) public var iteration: Int
    @NSManaged public var name: String
    @NSManaged public var content: String
    @NSManaged public var enumRaw: Int16        ; @EnumProperty(\ParagraphMO.enumRaw) public var test: Test
    
    convenience init() {
        self.init(context: CoreData.context)
    }
}

public enum Test: Int16 {
    case x
    case y
}
