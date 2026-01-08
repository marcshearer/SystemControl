//
//  Paragraph View Model.swift
//  SystemControl
//
//  Created by Marc Shearer on 19/09/2024.
//

import Combine
import SwiftUI
import CoreData

public class ParagraphViewModel : ViewModel, ObservableObject, RowViewModel {
    
    // Properties in core data model
    @Published private(set) var paragraphId: UUID = UUID()   ; public override var id: UUID { paragraphId }
    @Published public var nextParagraph: ParagraphViewModel?
    @Published public var childParagraph: ParagraphViewModel?
    @Published public var document: DocumentViewModel?
    @Published public var edition: EditionViewModel?
    @Published public var iteration: Int = 0
    @Published public var name: String = ""
    @Published public var content: NSAttributedString? = NSAttributedString(string:"Test")
       
    @Published public var nameMessage: String = ""
    @Published private(set) var saveMessage: String = ""
    @Published private(set) var canSave: Bool = false
    
    @Published public var row: Int?
    
    public let itemProvider = NSItemProvider(contentsOf: URL(string: "com.sheareronline.systemcontrol.paragraph")!)!
    
    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []
    
    override public init() {
        super.init()
        self.entity = paragraphEntity
        self.masterData = MasterData.shared.paragraphs
        self.setupMappings()
    }
    
    public convenience init(paragraphMO: ParagraphMO) {
        self.init()
        self.managedObject = paragraphMO
        self.revert()
    }
    
    public convenience init(document: DocumentViewModel, paragraphMO: ParagraphMO) {
        self.init(paragraphMO: paragraphMO)
        self.document = document
    }
    
    public override var newManagedObject: NSManagedObject { ParagraphMO() }
    
    public var paragraphMO: ParagraphMO? {
        get {
            managedObject as? ParagraphMO
        }
        set {
            managedObject = newValue
        }
    }

    public static func == (lhs: ParagraphViewModel, rhs: ParagraphViewModel) -> Bool {
        return lhs.paragraphId == rhs.paragraphId
    }
    
    private func setupMappings() {
    }
    
    public static func paragraph(id paragraphId: UUID?) -> ParagraphViewModel? {
        return ParagraphViewModel.getLookup(id: paragraphId)
    }
    
    static public func getLookup(id: UUID?) -> ParagraphViewModel? {
        return (id == nil ? nil : (MasterData.shared.paragraphs.array as! [ParagraphViewModel]).first(where: {$0.paragraphId == id}))
    }
    
    public override func beforeInsert() {
        assert(name != "", "Paragraph must have a non-blank name")
        assert(document != nil, "Paragraph must have a non-blank document")
    }
    
    public override var exists: Bool {
        return ParagraphViewModel.paragraph(id: id) != nil
    }
    
    public var hasData: Bool {
        !(content?.string.isEmpty ?? true)
    }
    
    override public var description: String {
        "Paragraph: \(self.name)"
    }
    
    override public var debugDescription: String { self.description }
}
