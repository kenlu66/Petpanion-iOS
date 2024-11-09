//
//  JournalEntry.swift
//  Petpanion
//
//  Created by Ruolin Dong on 11/9/24.
//

import Foundation

class Post {
    var title: String
    var body: String
    // list of imageData
    var imageDatas = [String]()
    
    init(title: String, body: String, imageDatas: [String] = [String]()) {
        self.title = title
        self.body = body
        self.imageDatas = imageDatas
    }
    
}
