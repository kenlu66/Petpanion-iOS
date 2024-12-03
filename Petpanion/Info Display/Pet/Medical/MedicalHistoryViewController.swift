//
//  MedicalHistoryViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MedicalHistoryViewController: UIViewController {
    
    var currentPet: Pet!
    
    let allergySegue = "MedicalToAllergies"
    let treatmentSegue = "MedicalToTreatment"
    let vaccineSegue = "MedicalToVaccine"
    
    let db = Firestore.firestore()
    
    var allergies: [MedicalInfo.Record] = []
    var vaccines: [MedicalInfo.Record] = []
    var treatments: [MedicalInfo.Record] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchRecords()
    }
    
    func fetchRecords() {
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let medicalRef = db.collection("users").document(userId).collection("pets").document(currentPet.petID).collection("medical records")

        medicalRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error retrieving pets: \(error.localizedDescription)")
                return
            }
            
            // Clear the arrays before adding new records
            self.vaccines = []
            self.allergies = []
            self.treatments = []
            
            // Iterate through each document in the snapshot
            for document in snapshot?.documents ?? [] {
                let medicalData = document.data()
                
                // Safely unwrap the "Medical type"
                guard let type = medicalData["Medical type"] as? String else {
                    print("Error: Missing medical type in document")
                    continue
                }
                
                // Safely unwrap the "Records" array
                if let records = medicalData["Records"] as? [[String: Any]] {
                    for record in records {
                        if let date = record["date"] as? String,
                           let description = record["description"] as? String,
                           let location = record["location"] as? String {
                            
                            let data = MedicalInfo.Record(description: description, date: date, location: location, category: type)
                            
                            switch type {
                            case "Allergy":
                                self.allergies.append(data)
                            case "Treatment":
                                self.treatments.append(data)
                            case "Vaccine":
                                self.vaccines.append(data)
                            default:
                                print("error fetching medical records")
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == allergySegue,
           let allergyVC = segue.destination as? AllergiesViewController {
            
        }
        
        if segue.identifier == treatmentSegue,
           let treatmentVC = segue.destination as? TreatmentsViewController {
            
        }
        
        if segue.identifier == vaccineSegue,
           let vaccineVC = segue.destination as? VaccinationsViewController {
            
        }
    }
}
