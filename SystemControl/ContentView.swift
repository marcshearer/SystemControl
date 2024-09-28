//
//  ContentView.swift
//  SystemControl
//
//  Created by Marc Shearer on 18/09/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext


    var body: some View {
        NavigationView {
            Button("Test") {
                let row = ParagraphMO()
                row.iteration = 2
                print(row.iterationRaw, row.iteration)
                row.test = .y
                print(row.enumRaw, row.test)
            }
        }
    }
}

