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
