//
//  MedicalInfo.swift
//  Petpanion
//
//  Created by Mengying Jin on 11/13/24.
//

import Foundation

import Foundation

class MedicalInfo {
    // Define structures for each medical category (allergy, vaccine, treatment)
    
    struct Allergy {
        var description: String
        var date: Date
        var location: String
    }
    
    struct Vaccine {
        var description: String
        var date: Date
        var location: String
    }
    
    struct Treatment {
        var description: String
        var date: Date
        var location: String
    }
    
    // Create arrays to hold multiple instances of allergies, vaccines, and treatments
    var allergies: [Allergy]
    var vaccines: [Vaccine]
    var treatments: [Treatment]
    
    init(allergies: [Allergy] = [], vaccines: [Vaccine] = [], treatments: [Treatment] = []) {
        self.allergies = allergies
        self.vaccines = vaccines
        self.treatments = treatments
    }
    
    // Add methods to add new allergies, vaccines, and treatments
    func addAllergy(description: String, date: Date, location: String) {
        let newAllergy = Allergy(description: description, date: date, location: location)
        allergies.append(newAllergy)
    }
    
    func addVaccine(description: String, date: Date, location: String) {
        let newVaccine = Vaccine(description: description, date: date, location: location)
        vaccines.append(newVaccine)
    }
    
    func addTreatment(description: String, date: Date, location: String) {
        let newTreatment = Treatment(description: description, date: date, location: location)
        treatments.append(newTreatment)
    }
}

