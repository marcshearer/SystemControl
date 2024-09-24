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
        }.onAppear {
            print("Hello")
        }
    }
}

