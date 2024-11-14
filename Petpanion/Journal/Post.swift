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
    var imageData: String
    
    init(title: String, body: String, imageData: String) {
        self.title = title
        self.body = body
        self.imageData = imageData
    }
    
}
