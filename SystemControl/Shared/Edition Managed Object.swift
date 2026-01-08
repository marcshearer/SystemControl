//
//  Edition Managed Object.swift
//  SystemControl
//
//  Created by Marc Shearer on 29/09/2024.
//

import CoreData

let editionEntity = Entity( "Edition",
                            EditionMO.self,
                            Attribute("editionId",      .uuid),
                            Attribute("document",     .uuid, suffix: "Id"),
                            Attribute("name",           .string),
                            Attribute("sequence",       .int16, suffix: "Raw"))

@objc(EdtionMO)
public class EditionMO: NSManagedObject, ManagedObject, Identifiable {
        
    public static let entity = editionEntity
    
    public var id: UUID { editionId }
    @NSManaged public var editionId: UUID
    @NSManaged public var documentId: UUID?
    @NSManaged public var name: String
    @NSManaged public var sequenceRaw: Int16
    
    convenience init() {
        self.init(context: CoreData.context)
        self.editionId = UUID()
    }
    
    @objc public var document: DocumentViewModel {
        get {
            if let documentId = documentId {
                DocumentViewModel.document(id: documentId) ?? DocumentViewModel()
            } else {
                DocumentViewModel()
            }
        }
        set {
            documentId = newValue.documentId
        }
    }
    
    @objc public var sequence: Int {
        get { Int(self.sequenceRaw) }
        set {self.sequenceRaw = Int16(newValue) }
    }
    
    public override var description: String {
        "Scorecard: \(document.name) Edition: \(self.name)"
    }
    
    public override var debugDescription: String { self.description }
}
