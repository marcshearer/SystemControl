//
//  Document Input View.swift
//  BridgeScore
//
//  Created by Marc Shearer on 11/02/2022.
//

import UIKit
import SwiftUI
import Combine

struct DocumentInputView: View {
    @ObservedObject var document: DocumentViewModel
    @State private var selection = AttributedTextSelection()
    @State private var paragraph = (MasterData.shared.paragraphs.array as! [ParagraphViewModel]).first!
    
    init(document: DocumentViewModel) {
        _document = ObservedObject(initialValue: document)
    }

    var body: some View {
        VStack {
            Spacer().frame(height: 20)
            HStack {
                Spacer().frame(width: 20)
                TextEditor(text: $paragraph.contentString, selection: $selection)
                Spacer().frame(width: 20)
            }
            Spacer().frame(height: 20)
            HStack {
                Spacer()
                Button("Save") {
                    paragraph.save()
                }
                .frame(width: 100)
                .frame(height: 40)
                .cornerRadius(8)
                .background(Palette.enabledButton.background)
                .foregroundColor(Palette.enabledButton.text)
                Spacer()
            }
            Spacer().frame(height: 20)
        }
    }
}

protocol DocumentResponder: UIView {
    var updateFocus: Bool {get set}
}
