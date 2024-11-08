//
//  Reminder.swift
//  Petpanion
//
//  Created by Kan Lu on 11/7/24.
//

import Foundation

struct Reminder {
    var id: String
    var title: String
    var time: Date
    var isCompleted: Bool
    var petId: String? // Optional to allow reminders without pets if needed
    var petName: String? // Optional pet name for display
}
