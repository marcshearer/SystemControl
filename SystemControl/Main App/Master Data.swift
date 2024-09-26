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
    
    @Published private(set) var fragments: [FragmentViewModel] = []
    
    public func load() {
        
            /// **Builds in-memory mirror of layouts, scorecards, players and locations with pointers to managed objects**
            /// Note that this infers that there will only ever be 1 instance of the app accessing the database
                
            // Read current data
        let fragmentMOs = CoreData.fetch(from: FragmentMO.entity.name) as! [FragmentMO]
        
            // Setup fragments
        self.fragments = []
        for fragmentMO in fragmentMOs {
            fragments.append(FragmentViewModel(fragmentMO: fragmentMO))
        }
    }
}
