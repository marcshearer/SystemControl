//
//  Document View Model.swift
//  SystemControl
//
//  Created by Marc Shearer on 28/09/2024.
//

import Combine
import SwiftUI
import CoreData

public class DocumentViewModel : ViewModel, ObservableObject {
    
    // Properties in core data model
    @Published private(set) var documentId: UUID = UUID() ; public override var id: UUID { documentId }
    @Published public var name: String = ""
    @Published public var sequence: Int = Int(Int32.max)
       
    @Published public var nameMessage: String = ""
    @Published private(set) var saveMessage: String = ""
    @Published private(set) var canSave: Bool = false
    
    public let itemProvider = NSItemProvider(contentsOf: URL(string: "com.sheareronline.systemcontrol.document")!)!
    
    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []
    
    override public init() {
        super.init()
        self.entity = documentEntity
        self.masterData = MasterData.shared.documents
        self.setupMappings()
    }
    
    public convenience init(documentMO: DocumentMO) {
        self.init()
        self.managedObject = documentMO
        self.revert()
    }
    
    public override var newManagedObject: NSManagedObject { DocumentMO() }

    public static func == (lhs: DocumentViewModel, rhs: DocumentViewModel) -> Bool {
        return lhs.documentId == rhs.documentId
    }
    
    private func setupMappings() {
        $name
            .receive(on: RunLoop.main)
            .map { (name) in
                return (name == "" ? "Document name must not be left blank. Either enter a valid name or delete this document" : (self.nameExists(name) ? "This name already exists on another document. The name must be unique" : ""))
            }
        .assign(to: \.saveMessage, on: self)
        .store(in: &cancellableSet)
        
        $name
            .receive(on: RunLoop.main)
            .map { (name) in
                return (name == "" ? "Must be non-blank" : (self.nameExists(name) ? "Must be unique" : ""))
            }
        .assign(to: \.nameMessage, on: self)
        .store(in: &cancellableSet)
              
        $saveMessage
            .receive(on: RunLoop.main)
            .map { (saveMessage) in
                return (saveMessage == "")
            }
        .assign(to: \.canSave, on: self)
        .store(in: &cancellableSet)
    }
    
    public override func beforeInsert() {
        assert(name != "", "Document must have a non-blank name")
    }
    
    public override var exists: Bool {
        return DocumentViewModel.document(id: documentId) != nil
    }
    
    public static func document(id documentId: UUID?) -> DocumentViewModel? {
        return DocumentViewModel.getLookup(id: documentId)
    }
    
    static public func getLookup(id: UUID?) -> DocumentViewModel? {
        return (id == nil ? nil : (MasterData.shared.documents.array as! [DocumentViewModel]).first(where: {$0.documentId == id}))
    }
    
    private func nameExists(_ name: String) -> Bool {
    return !(MasterData.shared.documents.array as! [DocumentViewModel]).filter({$0.name == name && $0.documentId != self.documentId}).isEmpty
    }
    
    override public var description: String {
        "Document: \(self.name)"
    }
    
    override public var debugDescription: String { self.description }
    
    public func backupCurrent() {
        UserDefault.currentId.set(self.documentId)
    }
    
    public func restoreCurrent() {
        // First try to read existing
        if let id = UserDefault.currentId.uuid {
            let savedDocument = DocumentViewModel.document(id: id)
            self.managedObject = savedDocument?.managedObject
        }
        
        // Now overwrite with backed up data
        self.documentId = UserDefault.currentId.uuid ?? UUID()
    }
}
