//
//  SystemControlApp.swift
//  SystemControl
//
//  Created by Marc Shearer on 18/09/2024.
//

import SwiftUI

@main
struct SystemControlApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
