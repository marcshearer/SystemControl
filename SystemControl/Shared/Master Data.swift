//
//  Master Data.swift
//  SystemControl
//
//  Created by Marc Shearer on 23/01/2022
//

import Foundation
import CoreData

class MasterData: ObservableObject {
    
    public static let shared = MasterData()
    
    @Published private(set) var paragraphs = WrappedArray()
    @Published private(set) var documents = WrappedArray()
    @Published private(set) var editions = WrappedArray()
    
    public func load() {
        
        /// **Builds in-memory mirror of layouts, scorecards, players and locations with pointers to managed objects**
        /// Note that this infers that there will only ever be 1 instance of the app accessing the database
            
        let createDefaultData = true
               
        // Setup documents
        let documentMOs = CoreData.fetch(from: DocumentMO.entity.name) as! [DocumentMO]

        self.documents.array = []
        for documentMO in documentMOs {
            documents.array.append(DocumentViewModel(documentMO: documentMO))
        }
        if documents.array.count == 0 && createDefaultData {
            // No documents - create defaults
            for document in DefaultData.documents {
                document.insert()
            }
        }
        
        // Setup editions
        let editionMOs = CoreData.fetch(from: EditionMO.entity.name) as! [EditionMO]
        
        self.editions.array = []
        for editionMO in editionMOs {
            editions.array.append(EditionViewModel(editionMO: editionMO))
        }
        if editions.array.count == 0 && createDefaultData {
            // No editions - create defaults
            for edition in DefaultData.editions(documents: (documents.array as! [DocumentViewModel])) {
                edition.insert()
            }
        }
        
        // Setup paragraphs
        let paragraphMOs = CoreData.fetch(from: ParagraphMO.entity.name) as! [ParagraphMO]
        
        self.paragraphs.array = []
        for paragraphMO in paragraphMOs {
            paragraphs.array.append(ParagraphViewModel(paragraphMO: paragraphMO))
        }
        if paragraphs.array.count == 0 && createDefaultData {
            // No paragraphs - create defaults
            for paragraph in DefaultData.paragraphs(documents: (documents.array as! [DocumentViewModel]), editions: (editions.array as! [EditionViewModel])) {
                paragraph.insert()
            }
        }
    }
}
