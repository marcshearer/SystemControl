//
//  Document.swift
//  BridgeScore
//
//  Created by Marc Shearer on 23/01/2022.
//

import UIKit

enum DocumentEntity {
    case paragraph
}

class Document {
    
    public static let current = Document()
    
    @Published private(set) var document: DocumentViewModel?
    @Published private(set) var paragraphs: [UUID:ParagraphViewModel] = [:]   // Board number
    
    
    public var hasData: Bool {
        return (paragraphs.compactMap{$0.value}.firstIndex(where: {$0.hasData}) != nil)
    }
    
    public func load(document: DocumentViewModel) {
        let documentFilter = NSPredicate(format: "documentId = %@", document.documentId as NSUUID)
        
        // Load paragraphs
        let paragraphMOs = CoreData.fetch(from: ParagraphMO.entity.name, filter: documentFilter) as! [ParagraphMO]
        
        paragraphs = [:]
        for paragraphMO in paragraphMOs {
            paragraphs[paragraphMO.paragraphId] = ParagraphViewModel(document: document, paragraphMO: paragraphMO)
        }
        for (_, paragraph) in paragraphs {
            if let childParagraphId = paragraph.paragraphMO!.childParagraphId {
                if let childParagraph = paragraphs[childParagraphId] {
                    paragraph.childParagraph = childParagraph
                } else {
                    fatalError("Invalid first child paragraph ID")
                }
            }
            if let nextParagraphId = paragraph.paragraphMO!.nextParagraphId {
                if let nextParagraph = paragraphs[nextParagraphId] {
                    paragraph.nextParagraph = nextParagraph
                } else {
                    fatalError("Invalid next paragraph ID")
                }
            }
        }
        
        // TODO: need to patch up any broken chains
        
        self.document = document
    }
    
    public func clear() {
        paragraphs = [:]
        document = nil
    }
    
    
    private var lastEntity: DocumentEntity?
    private var lastItemId: UUID?
    
    public func interimSave(entity: DocumentEntity? = nil, itemId: UUID? = nil) {
        if entity == nil || entity != lastEntity || itemId != lastItemId {
            if let lastItemId = lastItemId {
                switch lastEntity {
                case .paragraph:
                    if let paragraph = paragraphs[lastItemId] {
                        if paragraph.isNew || paragraph.changed {
                            save(paragraph: paragraph)
                        }
                    }
                default:
                    break
                }
            }
            lastEntity = entity
            lastItemId = itemId
        }
    }
    
    public func saveAll(document: DocumentViewModel) {
        
        assert(self.document == document, "Not the current document")
        
        for (_, paragraph) in paragraphs {
            if paragraph.changed {
                save(paragraph: paragraph)
            }
        }
    }
    
    public func removeAll(document: DocumentViewModel) {
        
        assert(self.document == document, "Not the current document")
        
        for (_, paragraph) in paragraphs {
            if !paragraph.isNew {
                remove(paragraph: paragraph)
            }
        }
        clear()
    }
        
    public func match(document: DocumentViewModel) -> Bool {
        return (self.document == document)
    }
        
    // MARK: - Paragraphs ================================================ -
    
    public func insert(paragraph: ParagraphViewModel) {
        assert(paragraph.document == document, "Paragraph is not in current document")
        assert(paragraph.isNew, "Cannot insert a paragraph which already has a managed object")
        CoreData.update(updateLogic: {
            // Add paragraph MO
            paragraph.paragraphMO = ParagraphMO()
            paragraph.updateMO()
            // Add to paragraph dictionary
            paragraphs[paragraph.paragraphMO!.paragraphId] = paragraph
        })
    }
    
    public func remove(paragraph: ParagraphViewModel) {
        assert(paragraph.document == document, "Paragraph is not in current document")
        assert(!paragraph.isNew, "Cannot remove a paragraph which doesn't already have a managed object")
        assert(paragraphs[paragraph.paragraphMO!.paragraphId] != nil, "Paragraph does not exist and cannot be deleted")
        CoreData.update(updateLogic: {
            // Delete paragraph MO
            CoreData.context.delete(paragraph.paragraphMO!)
            paragraphs[paragraph.paragraphMO!.paragraphId] = nil
        })
    }
    
    public func save(paragraph: ParagraphViewModel) {
        assert(paragraph.document == document, "Paragraph is not in current document")
        if paragraph.isNew {
            CoreData.update(updateLogic: {
                    // Add paragraph MO
                paragraph.paragraphMO = ParagraphMO()
                paragraph.updateMO()
                    // Add to paragraph dictionary
                paragraphs[paragraph.paragraphMO!.paragraphId] = paragraph
            })
        } else {
            assert(paragraphs[paragraph.paragraphMO!.paragraphId] == nil, "Board does not exist and cannot be updated")
            if paragraph.changed {
                CoreData.update(updateLogic: {
                        // Update paragraph MO
                    paragraph.updateMO()
                })
            }
        }
    }
}

protocol RowViewModel {
    var row: Int? {get}
}
