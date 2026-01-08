//
//  Document List View.swift
//  BridgeScore
//
//  Created by Marc Shearer on 21/01/2022.
//

import SwiftUI

struct DocumentListView: View {
    @Environment(\.verticalSizeClass) var sizeClass
    private let id = documentListViewId
    @StateObject private var selected = DocumentViewModel()
    @ObservedObject private var data = MasterData.shared
    @State private var title = "Documents"
    @State private var linkToNew = false
    @State private var linkToEdit = false
    @State private var highlighted = false
    @State private var startAt: UUID?
    @State private var tileColor = Palette.contrastTile
    var dropColor: Binding<PaletteColor> {
        Binding {
            tileColor
        } set: { (newValue) in
            tileColor = newValue
        }
        
    }
    
    var body: some View {
        let documents = MasterData.shared.documents.array as! [DocumentViewModel]
        
        var menuOptions = [BannerOption(text: "Backup", action: { MessageBox.shared.show("Backing up", cancelText: "Cancel", okText: "Continue", okAction: {Backup.shared.backup() ; MessageBox.shared.hide()})})]
        if Utility.isSimulator {
            menuOptions.append(
                BannerOption(text: "Restore", action: {
                    Backup.shared.restore(dateString: "Latest") }))
        }
        menuOptions.append(contentsOf:
                            [BannerOption(text: "About \(appName)", action: { MessageBox.shared.show("A Document Control app from\nShearer Online Ltd", showIcon: true, showVersion: true) })])
        
        return StandardView("Document List", slideInId: id, navigation: true) {
            
            VStack {
                Banner(title: $title, back: false, optionMode: .menu, menuImage: AnyView(Image(systemName: "gearshape")), menuTitle: "Setup", menuId: id, options: menuOptions)
                Spacer().frame(height: 8)
                
                ListTileView(color: dropColor) {
                    HStack {
                        Image(systemName: "plus.square")
                        Text("New Document")
                    }
                }
                .onTapGesture {
                    self.linkToNew = true
                }
                
                ScrollView {
                    Spacer().frame(height: 4)
                    ScrollViewReader { scrollViewProxy in
                        LazyVStack {
                            ForEach(documents) { (document) in
                                DocumentSummaryView(slideInId: id, document: document, highlighted: highlighted, selected: selected)
                                    .id(document.documentId)
                                    .onTapGesture {
                                        // Copy this entry to current document
                                        self.selected.copy(from: document)
                                        linkToEdit = true
                                    }
                            }
                        }
                        .onChange(of: self.startAt, initial: false) { (_, newValue) in
                            if let newValue = newValue {
                                scrollViewProxy.scrollTo(newValue, anchor: .top)
                                startAt = nil
                            }
                        }
                    }
                }
                Spacer()
            }
            .onAppear {
                if selected.documentId == nullUUID {
                    Utility.mainThread {
                        if let document = documents.first {
                            self.startAt = document.documentId
                        }
                    }
                    if UserDefault.currentUnsaved.bool {
                            // Unsaved version - restore it and link to it
                        let document = DocumentViewModel()
                        document.restoreCurrent()
                        self.selected.copy(from: document)
                        linkToEdit = true
                    }
                }
            }
            .navigationDestination(isPresented: $linkToEdit) {  }
        }
        .sheet(isPresented: $linkToEdit) {
            DocumentInputView(document: selected)
        }
    }
}

struct DocumentSummaryView: View {
    @Environment(\.verticalSizeClass) var sizeClass

    var slideInId: UUID
    @ObservedObject var document: DocumentViewModel
    @State var highlighted: Bool
    @ObservedObject var selected: DocumentViewModel
    
    var body: some View {
        if MyApp.format == .phone && !isLandscape {
            portraitPhoneView
        } else {
            normalView
        }
    }
    
    var normalView: some View {
        let color = (highlighted ? Palette.highlightTile : Palette.tile)
        return ListTileView(color: Binding.constant(color)) {
            GeometryReader { geometry in
                HStack {
                    VStack {
                        Spacer().frame(height: 4)
                        HStack {
                            description
                            Spacer()
                        }
                        .minimumScaleFactor(0.7)
                        .foregroundColor(color.contrastText)
                        .font(.title)
                        Spacer().frame(height: 12)
                    }
                    deleteButton
                }
            }
        }
    }
    
    var portraitPhoneView: some View {
        let color = (highlighted ? Palette.highlightTile : Palette.tile)
        return ListTileView(color: Binding.constant(color), height: 120) {
            VStack {
                Spacer().frame(height: 4)
                HStack {
                    description
                    Spacer()
                }
                .minimumScaleFactor(0.7)
                .foregroundColor(color.contrastText)
                .font(.title)
                HStack {
                    Spacer()
                    deleteButton
                    
                }
                Spacer().frame(height: 8)
            }
        }
    }
    
    var description: some View {
        HStack {
            Text(document.name)
        }
    }
    
    var portraitPhone: Bool {
        MyApp.format == .phone && !isLandscape
    }
    
    var deleteButton: some View {
        button("trash.circle.fill") {
            highlighted = true
            MessageBox.shared.show("This will delete the document permanently.\nAre you sure you want to do this?", cancelText: "Cancel", okText: "Confirm", cancelAction: {
                highlighted = false
            }, okAction: {
                highlighted = false
                document.remove()
            })
        }
    }
    
    func button(_ imageName: String, action: @escaping ()->()) -> some View {
        let color = (highlighted ? Palette.highlightTile : Palette.tile)
        return VStack {
            Spacer()
            Button {
                action()
            } label: {
                Image(systemName: imageName)
                    .font(.largeTitle)
                    .foregroundColor(color.contrastText)
            }
            Spacer()
        }
    }
}

