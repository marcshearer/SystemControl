//
//  Paragraph View Model.swift
//  SystemControl
//
//  Created by Marc Shearer on 19/09/2024.
//

import Combine
import SwiftUI
import CoreData

public class ParagraphViewModel : ViewModel, ObservableObject, Identifiable {
    
    // Properties in core data model
    @Published private(set) var paragraphId: UUID
    @Published public var nextParagraphId: UUID?
    @Published public var firstChildParagraphId: UUID?
    @Published public var document: String
    @Published public var edition: String
    @Published public var name: String
    @Published public var content: String
       
    @Published public var nameMessage: String = ""
    @Published private(set) var saveMessage: String = ""
    @Published private(set) var canSave: Bool = false
    
    public let itemProvider = NSItemProvider(contentsOf: URL(string: "com.sheareronline.systemcontrol.paragraph")!)!
    
    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []
    
    public init(document: String, edition: String) {
        self.paragraphId = UUID()
        self.document = document
        self.edition = edition
        self.name = ""
        self.content = ""
        super.init()
        self.entity = paragraphEntity
        self.masterData = MasterData.shared.paragraphs
        self.newManagedObject = ParagraphMO()
        self.setupMappings()
    }
    
    public convenience init(paragraphMO: ParagraphMO) {
        self.init(document: paragraphMO.document, edition: paragraphMO.edition)
        self.managedObject = paragraphMO
        self.revert()
    }
    
    public static func == (lhs: ParagraphViewModel, rhs: ParagraphViewModel) -> Bool {
        return lhs.paragraphId == rhs.paragraphId
    }
    
    private func setupMappings() {
        $name
            .receive(on: RunLoop.main)
            .map { (name) in
                return (name == "" ? "Paragraph name must not be left blank. Either enter a valid name or delete this paragraph" : (self.nameExists(name) ? "This name already exists on another paragraph. The name must be unique" : ""))
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
        assert(name == "", "Paragraph must have a non-blank name")
        assert(document == "", "Paragraph must have a non-blank document")
        assert(edition == "", "Paragraph must have a non-blank edition")
    }
    
    public override var exists: Bool {
        return paragraph(id: paragraphId) != nil
    }
    
    public func paragraph(id paragraphId: UUID?) -> ParagraphViewModel? {
        return (paragraphId == nil ? nil : MasterData.shared.paragraphs.first(where: {$0.paragraphId == paragraphId}))
    }
    
    private func nameExists(_ name: String) -> Bool {
        return !MasterData.shared.paragraphs.filter({$0.name == name && $0.paragraphId != self.paragraphId}).isEmpty
    }
    
    override public var description: String {
        "Paragraph: \(self.name)"
    }
    
    override public var debugDescription: String { self.description }
}
