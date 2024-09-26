//
//  Fragment View Model.swift
//  SystemControl
//
//  Created by Marc Shearer on 19/09/2024.
//

import Combine
import SwiftUI
import CoreData

public class FragmentViewModel : ViewModel, ObservableObject, Identifiable {
    
    // Properties in core data model
    @Published private(set) var fragmentId: UUID
    @Published public var nextFragmentId: UUID?
    @Published public var firstChildFragmentId: UUID?
    @Published public var document: String
    @Published public var edition: String
    @Published public var name: String
    @Published public var content: String
       
    @Published public var nameMessage: String = ""
    @Published private(set) var saveMessage: String = ""
    @Published private(set) var canSave: Bool = false
    
    public let itemProvider = NSItemProvider(contentsOf: URL(string: "com.sheareronline.systemcontrol.fragment")!)!
    
    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []
    
    public init(document: String, edition: String) {
        self.fragmentId = UUID()
        self.document = document
        self.edition = edition
        self.name = ""
        self.content = ""
        super.init()
        self.entity = fragmentEntity
        self.masterData = MasterData.shared.fragments
        self.newManagedObject = FragmentMO()
        self.setupMappings()
    }
    
    public convenience init(fragmentMO: FragmentMO) {
        self.init(document: fragmentMO.document, edition: fragmentMO.edition)
        self.managedObject = fragmentMO
        self.revert()
    }
    
    public static func == (lhs: FragmentViewModel, rhs: FragmentViewModel) -> Bool {
        return lhs.fragmentId == rhs.fragmentId
    }
    
    private func setupMappings() {
        $name
            .receive(on: RunLoop.main)
            .map { (name) in
                return (name == "" ? "Fragment name must not be left blank. Either enter a valid name or delete this fragment" : (self.nameExists(name) ? "This name already exists on another fragment. The name must be unique" : ""))
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
        assert(name == "", "Fragment must have a non-blank name")
        assert(document == "", "Fragment must have a non-blank document")
        assert(edition == "", "Fragment must have a non-blank edition")
    }
    
    public override var exists: Bool {
        return fragment(id: fragmentId) != nil
    }
    
    public func fragment(id fragmentId: UUID?) -> FragmentViewModel? {
        return (fragmentId == nil ? nil : MasterData.shared.fragments.first(where: {$0.fragmentId == fragmentId}))
    }
    
    private func nameExists(_ name: String) -> Bool {
        return !MasterData.shared.fragments.filter({$0.name == name && $0.fragmentId != self.fragmentId}).isEmpty
    }
    
    override public var description: String {
        "Fragment: \(self.name)"
    }
    
    override public var debugDescription: String { self.description }
}
