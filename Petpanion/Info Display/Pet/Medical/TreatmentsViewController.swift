//
//  TreatmentsViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth

protocol addTreatment {
    func addRecord(newRecord: MedicalInfo.Record)
}

class TreatmentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addTreatment {
    
    // variables
    let medicalInfo = MedicalInfo()
    let userManager = UserManager()
    var treatmentList: [MedicalInfo.Record] = []
    var docID = ""
    var delegate: UIViewController!
    var pet: Pet!

    @IBOutlet weak var tableView: UITableView!
    let recordCreationSegue = "TreatmentToCreation"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treatmentList.count
    }
    
    // set up cell view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TreatmentCell", for: indexPath)
        let row = indexPath.row // Index
        // Put string name into cell
        let record = """
        \(treatmentList[row].date)
            \(treatmentList[row].description)
            \(treatmentList[row].location)
        """
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = record
        
        return cell
    }
    
    // Swipe to Delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removedRecord = treatmentList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Ensure the user is authenticated
            guard let userId = Auth.auth().currentUser?.uid else {
                print("Error: user not authenticated")
                // revert local changes if needed
                treatmentList.insert(removedRecord, at: indexPath.row)
                tableView.reloadData()
                return
            }
            
            // Remove the record from the local medicalInfo instance
            medicalInfo.removeRecord(category: "Treatment", record: removedRecord)
            
            // Update Firebase
            Task {
                do {
                    try await userManager.updateMedicalRecord(for: userId,
                                                               records: self.treatmentList,
                                                               docID: docID,
                                                               petID: pet.petID,
                                                               type: "Treatment")
                } catch {
                    print("Failed to update backend after deletion: \(error)")
                    // Revert local changes if backend update fails
                    self.treatmentList.insert(removedRecord, at: indexPath.row)
                    self.medicalInfo.addRecord(category: "Treatment", record: removedRecord)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // set up segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == recordCreationSegue,
           let creationVC = segue.destination as? MedicalRecordCreationVC {
            // Pass the current type
            creationVC.currentType = "Treatment"
            creationVC.docID = docID
            creationVC.delegate = self // pointer back to mainVC
        }
    }
    
    // update record in firebase and table view
    func addRecord(newRecord: MedicalInfo.Record) {
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("error: treatment user not auth")
            return
        }
        
        treatmentList.append(newRecord)
        medicalInfo.addRecord(category: "Treatment", record: newRecord)
        
        Task {
            do {
                try await userManager.updateMedicalRecord(for: userId, records: self.treatmentList, docID: docID, petID: pet.petID, type: "Treatment")
            } catch {
                throw error
            }
        }
        
        tableView.reloadData()
    }

}
