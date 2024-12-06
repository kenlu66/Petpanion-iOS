import Foundation

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
