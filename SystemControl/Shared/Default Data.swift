//
//  Default Data.swift
//  SystemControl
//
//  Created by Marc Shearer on 23/01/2022.
//

import Foundation

class DefaultData {
    
    public class var documents: [DocumentViewModel] {
        get {
            let document1 = DocumentViewModel()
            document1.name = "Weak NT, 4-card majors, 3 weak 2s"
            document1.sequence = 1
            return [document1]
        }
    }
    
    public class func editions(documents: [DocumentViewModel]) ->[EditionViewModel] {
        let edition1 = EditionViewModel()
        edition1.document = documents.first(where: {$0.name == "Weak NT, 4-card majors, 3 weak 2s"})
        edition1.name = "Jack"
        edition1.sequence = 1
            
        let edition2 = EditionViewModel()
        edition2.document = documents.first(where: {$0.name == "Weak NT, 4-card majors, 3 weak 2s"})
        edition2.name = "Michele"
        edition2.sequence = 2

        let edition3 = EditionViewModel()
        edition3.document = documents.first(where: {$0.name == "Weak NT, 4-card majors, 3 weak 2s"})
        edition3.name = "George"
        edition3.sequence = 3

        return [edition1, edition2, edition3]
    }
    
    public class func paragraphs(documents: [DocumentViewModel], editions: [EditionViewModel]) ->[ParagraphViewModel] {
        let paragraph1 = ParagraphViewModel()
        paragraph1.document = documents.first(where: {$0.name == "Weak NT, 4-card majors, 3 weak 2s"})
        paragraph1.edition = editions.first(where: {$0.name == "Jack"})
        paragraph1.name = "Opening Bids"

        return [paragraph1]
    }
}
