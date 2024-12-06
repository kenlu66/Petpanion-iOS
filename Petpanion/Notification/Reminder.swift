//
//  Reminder.swift
//  Petpanion
//
//  Created by Kan Lu on 11/7/24.
//

import Foundation

struct MyReminder {
    var identifier: String
    var title: String
    var body: String
    var date: Date
    var tag: String
    var location: String
    var flagged: Bool = false
    var completed: Bool = false // New property to track completion
    
    init(identifier: String, title: String, body: String, date: Date, tag: String, location: String, flagged: Bool, completed: Bool) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.date = date
        self.tag = tag
        self.location = location
        self.flagged = flagged
        self.completed = completed
    }
}
