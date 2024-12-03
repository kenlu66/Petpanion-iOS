//
//  MedicalHistoryViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol updateData {
    func updateFirebase(userID: String, record: MedicalInfo.Record, docID: String)
}

class MedicalHistoryViewController: UIViewController, updateData {
    
    var currentPet: Pet!
    
    let allergySegue = "MedicalToAllergies"
    let treatmentSegue = "MedicalToTreatment"
    let vaccineSegue = "MedicalToVaccine"
    
    let db = Firestore.firestore()
    let medicalInfo = MedicalInfo()
    
    var allergies: [MedicalInfo.Record] = []
    var vaccines: [MedicalInfo.Record] = []
    var treatments: [MedicalInfo.Record] = []
    var docIDA: String!
    var docIDV: String!
    var docIDT: String!

    override func viewDidLoad() {
        super.viewDidLoad()

//        fetchRecords()
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
            
            self.vaccines = []
            self.allergies = []
            self.treatments = []
            
            for document in snapshot?.documents ?? [] {
                print("in doc")
                let medicalData = document.data()
                
                guard let type = medicalData["Medical type"] as? String else {
                    print("Error: Missing medical type in document")
                    continue
                }
                
                if let docID = medicalData["Document ID"] as? String {
                    switch type {
                    case "Allergy":
                        self.docIDA = docID
                    case "Treatment":
                        self.docIDT = docID
                    case "Vaccine":
                        self.docIDV = docID
                    default:
                        print("error fetching medical document id")
                    }
                    
                    print("Got doc ids")
                }
                print("before reading records")
                if let records = medicalData["Records"] as? [[String: Any]] {
                    for record in records {
                        print("reading record")
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
            allergyVC.allergyList = allergies
            allergyVC.docID = docIDA
            allergyVC.delegate = self
        }
        
        if segue.identifier == treatmentSegue,
           let treatmentVC = segue.destination as? TreatmentsViewController {
            treatmentVC.treatmentList = treatments
            treatmentVC.docID = docIDT
            treatmentVC.delegate = self
        }
        
        if segue.identifier == vaccineSegue,
           let vaccineVC = segue.destination as? VaccinationsViewController {
            vaccineVC.vaccineList = vaccines
            vaccineVC.docID = docIDV
            vaccineVC.delegate = self
        }
    }
    
    func updateFirebase(userID: String, record: MedicalInfo.Record, docID: String) {
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        medicalInfo.updateFirebase(userID: userId, record: record, docID: docID, petID: currentPet.petID)
    }
}
