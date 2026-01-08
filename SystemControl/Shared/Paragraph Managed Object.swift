//
//  Paragraph Managed Object.swift
//  SystemControl
//
//  Created by Marc Shearer on 18/09/2024.
//

import CoreData

let paragraphEntity = Entity( "Paragraph",
                              ParagraphMO.self,
                              Attribute("paragraphId",      .uuid),
                              Attribute("nextParagraph",  .uuid, isOptional: true, suffix: "Id"),
                              Attribute("childParagraph", .uuid, isOptional: true, suffix: "Id"),
                              Attribute("document",       .uuid, suffix: "Id"),
                              Attribute("edition",        .uuid, suffix: "Id"),
                              Attribute("iteration",        .int16, suffix: "16"),
                              Attribute("name",             .string),
                              Attribute("content",          .attributedString, isOptional: true))

@objc(ParagraphMO)
public class ParagraphMO: NSManagedObject, ManagedObject, Identifiable {
    
    public static let entity = paragraphEntity
    
    public var id: UUID { self.paragraphId }
    @NSManaged public var paragraphId: UUID
    @NSManaged public var nextParagraphId: UUID?
    @NSManaged public var childParagraphId: UUID?
    @NSManaged public var documentId: UUID
    @NSManaged public var editionId: UUID
    @NSManaged public var iteration16: Int16
    @NSManaged public var name: String
    @NSManaged public var content: NSAttributedString?

    convenience init() {
        self.init(context: CoreData.context)
        self.paragraphId = UUID()
    }
    
    @objc public var nextParagraph: ParagraphViewModel? {
        get {
            if let nextParagraphId = nextParagraphId {
                ParagraphViewModel.paragraph(id: nextParagraphId) ?? ParagraphViewModel()
            } else {
                ParagraphViewModel()
            }
        }
        set {
            nextParagraphId = newValue?.paragraphId
        }
    }
    
    @objc public var childParagraph: ParagraphViewModel? {
        get {
            if let childParagraphId = childParagraphId {
                ParagraphViewModel.paragraph(id: childParagraphId) ?? ParagraphViewModel()
            } else {
                ParagraphViewModel()
            }
        }
        set {
            childParagraphId = newValue?.paragraphId
        }
    }
    
    @objc public var document: DocumentViewModel {
        get {
            DocumentViewModel.document(id: documentId) ?? DocumentViewModel()
        }
        set {
            documentId = newValue.documentId
        }
    }
    
    @objc public var edition: EditionViewModel {
        get {
            EditionViewModel.edition(id: editionId) ?? EditionViewModel()
        }
        set {
            editionId = newValue.editionId
        }
    }
    
    @objc public var iteration: Int {
        get { Int(self.iteration16) }
        set {self.iteration16 = Int16(newValue) }
    }
    
    public override var description: String {
        "Scorecard: \(self.name)"
    }
    public override var debugDescription: String { self.description }
}
