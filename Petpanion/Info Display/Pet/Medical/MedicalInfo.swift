import Foundation

class MedicalInfo {
    
    struct Record {
        var description: String
        var date: String
        var location: String
        var category: String  // Allergy, Vaccine, or Treatment
    }

    var allergies: [Record] = []
    var vaccines: [Record] = []
    var treatments: [Record] = []
    
    // Instance method to get records by category
    func getRecords(byCategory category: String) -> [Record] {
        switch category {
        case "Allergy":
            return allergies
        case "Vaccine":
            return vaccines
        case "Treatment":
            return treatments
        default:
            return []
        }
    }

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
