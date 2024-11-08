//
//  NotificationScheduler.swift
//  Petpanion
//
//  Created by Kan Lu on 11/7/24.
//

import UserNotifications
import Foundation

class NotificationScheduler {
    static let shared = NotificationScheduler() // Singleton for easy access

    func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = "It's time for: \(reminder.title)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: reminder.time.timeIntervalSinceNow,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: reminder.id,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
}

