//
//  Event.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/30/24.
//

import Foundation

var eventsList = [Event]()

// event class for calendar
class Event {
    var id:Int!
    var name:String!
    var date:Date!
    
    func eventsForDate(date:Date) -> [Event] {
        var daysEvents = [Event]()
        for event in eventsList {
            if (Calendar.current.isDate(event.date, inSameDayAs: date)) {
                daysEvents.append(event)
            }
        }
        return daysEvents
    }
}
