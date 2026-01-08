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
    
    init(document: DocumentViewModel) {
        _document = ObservedObject(initialValue: document)
    }

    var body: some View {
        // TextEditor(text: $text, selection: $selection)
    }
}

protocol DocumentResponder: UIView {
    var updateFocus: Bool {get set}
}
