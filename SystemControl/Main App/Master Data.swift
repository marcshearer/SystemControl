//
//  Master Data.swift
//  BridgeScore
//
//  Created by Marc Shearer on 23/01/2022
//

import Foundation
import CoreData

class MasterData: ObservableObject {
    
    public static let shared = MasterData()
    
    @Published private(set) var paragraphs: [ParagraphViewModel] = []
    
    public func load() {
        
            /// **Builds in-memory mirror of layouts, scorecards, players and locations with pointers to managed objects**
            /// Note that this infers that there will only ever be 1 instance of the app accessing the database
                
            // Read current data
        let paragraphMOs = CoreData.fetch(from: ParagraphMO.entity.name) as! [ParagraphMO]
        
            // Setup paragraphs
        self.paragraphs = []
        for paragraphMO in paragraphMOs {
            paragraphs.append(ParagraphViewModel(paragraphMO: paragraphMO))
        }
    }
}
