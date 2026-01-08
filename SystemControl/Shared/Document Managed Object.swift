//
//  Document Managed Object.swift
//  SystemControl
//
//  Created by Marc Shearer on 28/09/2024.
//

import SwiftData
import SwiftUI

let documentEntity = Entity( "Document",
                             DocumentMO.self,
                             Attribute("documentId",            .uuid),
                             Attribute("name",                  .string),
                             Attribute("sequence",              .int16, suffix: "16"))

@objc(DocumentMO)
public class DocumentMO: NSManagedObject, ManagedObject, Identifiable {
    
    public static let entity = documentEntity
    
    public var id: UUID { self.documentId }
    @NSManaged public var documentId: UUID
    @NSManaged public var name: String
    @NSManaged public var sequence16: Int16
    
    convenience init() {
        self.init(context: CoreData.context)
        self.documentId = UUID()
    }
    
    @objc public var sequence: Int {
        get { Int(self.sequence16) }
        set {self.sequence16 = Int16(newValue) }
    }
    
    public override var description: String {
        "Scorecard: \(self.name)"
    }
    public override var debugDescription: String { self.description }
}
