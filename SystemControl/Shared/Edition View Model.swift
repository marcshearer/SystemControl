//
//  Edition.swift
//  SystemControl
//
//  Created by Marc Shearer on 29/09/2024.
//

import Combine
import SwiftUI
import CoreData

public class EditionViewModel : ViewModel, ObservableObject {
    
    // Properties in core data model
    @Published private(set) var editionId: UUID = UUID() ; public var id: UUID { get { editionId }}
    @Published public var name: String = ""
       
    @Published public var nameMessage: String = ""
    @Published private(set) var saveMessage: String = ""
    @Published private(set) var canSave: Bool = false
    
    public let itemProvider = NSItemProvider(contentsOf: URL(string: "com.sheareronline.systemcontrol.edition")!)!
    
    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []
    
    override public init() {
        super.init()
        self.entity = editionEntity
        self.masterData = MasterData.shared.editions
        self.newManagedObject = EditionMO()
        self.setupMappings()
    }
    
    public convenience init(editionMO: EditionMO) {
        self.init()
        self.managedObject = editionMO
        self.revert()
    }
    
    public static func == (lhs: EditionViewModel, rhs: EditionViewModel) -> Bool {
        return lhs.editionId == rhs.editionId
    }
    
    private func setupMappings() {
        $name
            .receive(on: RunLoop.main)
            .map { (name) in
                return (name == "" ? "Edition name must not be left blank. Either enter a valid name or delete this edition" : (self.nameExists(name) ? "This name already exists on another edition. The name must be unique" : ""))
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
        assert(name == "", "Edition must have a non-blank name")
    }
    
    public override var exists: Bool {
        return edition(id: editionId) != nil
    }
    
    public func edition(id editionId: UUID?) -> EditionViewModel? {
        return EditionViewModel.getLookup(id: editionId)
    }
    
    static public func getLookup(id editionId: UUID?) -> EditionViewModel? {
        return (editionId == nil ? nil : MasterData.shared.editions.first(where: {$0.editionId == editionId})) as? Self
    }
    
    private func nameExists(_ name: String) -> Bool {
        return !MasterData.shared.editions.filter({$0.name == name && $0.editionId != self.editionId}).isEmpty
    }
    
    override public var description: String {
        "Edition: \(self.name)"
    }
    
    override public var debugDescription: String { self.description }
}
