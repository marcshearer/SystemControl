//
//  Document Managed Object.swift
//  SystemControl
//
//  Created by Marc Shearer on 28/09/2024.
//

import CoreData

let documentEntity = Entity( "Document",
                             DocumentMO.self,
                             Attribute("documentId",            .UUIDAttributeType),
                             Attribute("name",                  .stringAttributeType))
@objc(DocumentMO)
public class DocumentMO: NSManagedObject, ManagedObject, Identifiable {
    
    public static let entity = documentEntity
    
    @NSManaged public var documentId: UUID
    @NSManaged public var name: String
    
    convenience init() {
        self.init(context: CoreData.context)
    }
}
