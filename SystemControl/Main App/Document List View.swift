//
//  Document List View.swift
//  BridgeScore
//
//  Created by Marc Shearer on 21/01/2022.
//

import SwiftUI

struct DocumentListView: View, DropDelegate {
    @Environment(\.verticalSizeClass) var sizeClass
    private let id = documentListViewId
    private let inputId = UUID()
    private let uttypes = [UTType.fileURL]
    @StateObject private var selected = DocumentViewModel(documentId: nullUUID)
    @StateObject private var filterValues = DocumentFilterValues(.list)
    @ObservedObject private var data = MasterData.shared
    @State private var title = "Documents"
    @State private var layout = LayoutViewModel()
    @State private var layoutSelected = false
    @State private var linkToNew = false
    @State private var linkToEdit = false
    @State private var linkToLayouts = false
    @State private var linkToPlayers = false
    @State private var linkToLocations = false
    @State private var linkToStats = false
    @State private var linkToDownload = false
    @State private var highlighted = false
    @State private var startAt: UUID?
    @State private var closeFilter = false
    @State private var importDocument: ImportSource = .none
    @State private var importTapped: ImportSource = .none
    @State private var dropEntered: Bool = false
    @State private var tileColor = Palette.contrastTile
    var dropColor: Binding<PaletteColor> {
        Binding {
            tileColor
        } set: { (newValue) in
            tileColor = newValue
        }
        
    }

    var body: some View {
        let documents = MasterData.shared.documents.filter({filterValues.filter($0)})
        
        var menuOptions = [BannerOption(text: "Statistics", action: { linkToStats = true }),
                           BannerOption(text: "Templates", action: { linkToLayouts = true }),
                           BannerOption(text: "Players",  action: { linkToPlayers = true }),
                           BannerOption(text: "Locations", action: { linkToLocations = true }),
                           BannerOption(text: "Import BBO Names", action: { ImportBBO.importNames() }),
                           BannerOption(text: "Backup", action: { MessageBox.shared.show("Backing up", cancelText: "Cancel", okText: "Continue", okAction: {Backup.shared.backup() ; MessageBox.shared.hide()})})]
        if Utility.isSimulator {
            menuOptions.append(
                           BannerOption(text: "Restore", action: {
                              Backup.shared.restore(dateString: "Latest") }))
        }
        menuOptions.append(contentsOf:
                          [BannerOption(text: "About \(appName)", action: { MessageBox.shared.show("A Bridge scoring app from\nShearer Online Ltd", showIcon: true, showVersion: true) })])
        
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
                /*.onDrop(of: uttypes, delegate: self)
                    In case you ever need to drop import files on this list
                */
                .onTapGesture {
                    self.linkToNew = true
                }
                
                ScrollView {
                    Spacer().frame(height: 4)
                    DocumentFilterView(id: id, filterValues: filterValues, closeFilter: $closeFilter)
                    ScrollViewReader { scrollViewProxy in
                        LazyVStack {
                            ForEach(documents) { (document) in
                                DocumentSummaryView(slideInId: id, document: document, highlighted: highlighted, selected: selected, importTapped: $importTapped)
                                    .id(document.documentId)
                                    .onTapGesture {
                                        // Copy this entry to current document
                                        self.selected.copy(from: document)
                                        linkAction()
                                    }
                            }
                        }
                        .onChange(of: importTapped, initial: false) { (_, newValue) in
                            if newValue != .none {
                                linkAction(importTapped: newValue)
                            }
                            importTapped = .none
                        }
                        .onChange(of: self.startAt, initial: false) { (_, newValue) in
                            if let newValue = newValue {
                                scrollViewProxy.scrollTo(newValue, anchor: .top)
                                startAt = nil
                            }
                        }
                        .onChange(of: self.closeFilter, initial: false) { (_, newValue) in
                            if newValue {
                                if let document = data.documents.first {
                                    self.startAt = document.documentId
                                }
                                closeFilter = false
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
                            if  filterValues.isClear {
                                self.startAt = document.documentId
                            }
                        }
                    }
                    if UserDefault.currentUnsaved.bool {
                        // Unsaved version - restore it and link to it
                        let document = DocumentViewModel()
                        document.restoreCurrent()
                        self.selected.copy(from: document)
                        Document.current.load(document: document)
                        linkToEdit = true
                    }
                }
            }
            .navigationDestination(isPresented: $linkToLayouts) { LayoutSetupView() }
            .navigationDestination(isPresented: $linkToPlayers) { PlayerSetupView() }
            .navigationDestination(isPresented: $linkToLocations) { LocationSetupView() }
            .navigationDestination(isPresented: $linkToStats) { StatsView() }
            .navigationDestination(isPresented: $linkToEdit) { DocumentInputView(document: selected, importDocument: importDocument) }
        }
        .sheet(isPresented: $linkToNew, onDismiss: {
            if layoutSelected {
                self.selected.reset(from: layout)
                Document.current.load(document: selected)
                importDocument = .none
                linkToEdit = true
            }
        }) {
            LayoutListView(selected: $layoutSelected, layout: $layout)
        }
    }
    
    private func linkAction(importTapped: ImportSource = .none) {
        Document.current.load(document: self.selected)
        if true || !Document.current.isSensitive { // TODO Reinstate password control?
            importDocument = importTapped
            linkToEdit = true
        } else {
            LocalAuthentication.authenticate(reason: "You must authenticate to access the document detail") {
                importDocument = importTapped
                linkToEdit = true
            } failure: {
                Document.current.clear()
            }
        }
    }
    
    // MARK: - Drop delegates
    
    func validateDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        dropColor.wrappedValue = Palette.enabledButton
    }
    
    func dropExited(info: DropInfo) {
        dropColor.wrappedValue = Palette.contrastTile
    }
    
    func performDrop(info: DropInfo) -> Bool {
        var dropped: [(filename: String, conteents: String)] = []
        for item in info.itemProviders(for: [UTType.data]) {
            if let filename = item.suggestedName {
                item.loadItem(forTypeIdentifier: UTType.data.identifier) { (url, error) in
                    if let url = url as? URL {
                        if let data = try? Data(contentsOf: url), let contents = String(data: data, encoding: .utf8) {
                            dropped.append((filename, contents))
                        }
                    }
                }
            }
        }
        
        dropColor.wrappedValue = Palette.contrastTile
        AudioServicesPlaySystemSound(SystemSoundID(1304))
        return true
    }
}

struct DocumentSummaryView: View {
    @Environment(\.verticalSizeClass) var sizeClass

    var slideInId: UUID
    @ObservedObject var document: DocumentViewModel
    @State var highlighted: Bool
    @ObservedObject var selected: DocumentViewModel
    @Binding var importTapped: ImportSource
    @State var selectImport = false
    @State var importSelected: Int?
    
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
                            position.frame(width: 100)
                            score.frame(width: 150)
                            Spacer().frame(width: 30)
                        }
                        .minimumScaleFactor(0.7)
                        .foregroundColor(color.contrastText)
                        .font(.title)
                        HStack {
                            datePlayed
                            Spacer()
                            HStack {
                                playedWith
                                Spacer()
                            }
                            .frame(width: geometry.size.width * 0.3)
                            playedAt
                            .frame(width: geometry.size.width * 0.37)
                        }
                        .foregroundColor(color.text)
                        .font(.callout)
                        .minimumScaleFactor(0.5)
                        Spacer().frame(height: 12)
                    }
                    importButton
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
                    score
                }
                .minimumScaleFactor(0.7)
                .foregroundColor(color.contrastText)
                .font(.title)
                HStack {
                    VStack {
                        HStack {
                            datePlayed
                            Spacer()
                        }
                        Spacer().frame(height: 2)
                        HStack {
                            playedWith
                            Spacer()
                        }
                        Spacer().frame(height: 2)
                        HStack {
                            playedAt
                            Spacer()
                        }
                    }
                    .foregroundColor(color.text)
                    .font(.callout)
                    .minimumScaleFactor(0.5)
                    deleteButton
                    
                }
                Spacer().frame(height: 8)
            }
        }
    }
    
    var description: some View {
        HStack {
            let text = document.desc + (document.comment == "" || portraitPhone ? "" : " (\(document.comment))") + (document.scorer?.isSelf ?? true || portraitPhone ? "" : " as \(document.scorer!.name)")
            Text(text).lineLimit(portraitPhone ? 1 : 2)
                .if(MyApp.format == .phone) { (view) in
                    view.minimumScaleFactor(1)
                }
        }
    }
    
    var portraitPhone: Bool {
        MyApp.format == .phone && !isLandscape
    }
    
    var position: some View {
        HStack {
            if document.position != 0 && document.entry != 0 {
                Text("\(document.position) / \(document.entry)")
                    
            }
        }
    }
    
    var score: some View {
        HStack {
            if document.score != nil {
                if !portraitPhone {
                    Text(document.scoreString)
                } else {
                    Text(document.score!.toString(places: document.type.matchPlaces))
                }
            }
        }
    }
    
    var datePlayed: some View {
        Text(Utility.dateString(Date.startOfDay(from: document.date)!, format: "dd MMM yyyy", style: .short, doesRelativeDateFormatting: true)).font(.callout).bold()
    }
    
    var playedWith: some View {
        HStack {
            if document.type.players > 1 {
                HStack {
                    Text("With: ")
                    Text(document.partner?.name ?? "").font(.callout).bold()
                    Spacer()
                }
            }
        }
    }
    
    var playedAt: some View {
        HStack {
            HStack {
                Text("At: ")
                Text(document.location?.name ?? "").font(.callout).bold()
                Spacer()
            }
        }
    }
    
    var importButton: some View {
        let color = (highlighted ? Palette.highlightTile : Palette.tile)
        return HStack {
            if document.importSource == .none && !document.manualTotals {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        PopupMenu(id: slideInId, field: $importSelected, values: ImportSource.validCases.map{$0.string}, animation: .none, top: geometry.frame(in: .global).minY - 30, left: geometry.frame(in: .global).minX - 290, width: 300) { (selectedIndex) in
                            if let selectedIndex = selectedIndex {
                                importTapped = ImportSource.validCases[selectedIndex]
                                selected.copy(from: document)
                            }
                            importSelected = nil
                        } label: {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(color.contrastText)
                        }
                        Spacer()
                    }
                }
            }
        }
        .frame(width: 50)
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
