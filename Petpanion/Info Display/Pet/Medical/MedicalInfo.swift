//
//  MedicalInfo.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import Foundation

// medical record class to store require info for easier data transfer
class MedicalInfo {
    
    struct Record {
        var description: String
        var date: String
        var location: String
    }

    var allergies: [Record] = []
    var vaccines: [Record] = []
    var treatments: [Record] = []

    // Add records to each category
    func addRecord(category: String, record: Record) {
        switch category {
        case "Allergy":
            allergies.append(record)
        case "Vaccine":
            vaccines.append(record)
        case "Treatment":
            treatments.append(record)
        default:
            break
        }
    }
}
