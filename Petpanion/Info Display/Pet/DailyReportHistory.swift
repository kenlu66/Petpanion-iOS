//
//  DailyReportHistory.swift
//  Petpanion
//
//  Created by Mengying Jin on 11/13/24.
//

import Foundation

class DailyReportHistory {
    
    var reports: [DailyReport]  // Array of daily reports
    
    // Struct for each daily report
    struct DailyReport {
        var date: String
        var foodInfo: FoodInfo
        var waterInfo: WaterInfo
        var playtimeInfo: PlaytimeInfo
        var moodInfo: MoodInfo
    }
    
    struct FoodInfo {
        var required: Float
        var actual: Float
    }
    
    struct WaterInfo {
        var required: Float
        var actual: Float
    }
    
    struct PlaytimeInfo {
        var required: Float
        var actual: Float
    }
    
    struct MoodInfo {
        var mood: String
        var energyLvl: String
    }
    
    // Constructor
    init() {
        self.reports = []
    }
    
    // Method to add a new daily report
    func addReport(date: String, foodRequired: Float, foodActual: Float, waterRequired: Float, waterActual: Float, playtimeRequired: Float, playtimeActual: Float, mood: String, energyLvl: String) {
        let report = DailyReport(date: date, foodInfo: FoodInfo(required: foodRequired, actual: foodActual),
                                  waterInfo: WaterInfo(required: waterRequired, actual: waterActual),
                                  playtimeInfo: PlaytimeInfo(required: playtimeRequired, actual: playtimeActual),
                                 moodInfo: MoodInfo(mood: mood, energyLvl: energyLvl))
        self.reports.append(report)
    }
    
    // Method to retrieve the report for a specific date
    func getReport(forDate date: String) -> DailyReport? {
        return self.reports.first { $0.date == date }
    }
    
}

