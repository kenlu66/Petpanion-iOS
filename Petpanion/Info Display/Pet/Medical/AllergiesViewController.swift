//
//  AllergiesViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth

protocol addRecord {
    func addRecord(newRecord: MedicalInfo.Record)
}
class AllergiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addRecord {
    
    let medicalInfo = MedicalInfo()
    let userManager = UserManager()
    
    var allergyList: [MedicalInfo.Record] = []
    var pet: Pet!
    var docID: String!
    var delegate: UIViewController!

    @IBOutlet weak var tableView: UITableView!
    let recordCreationSegue = "AllergiesToCreation"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allergyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllergyCell", for: indexPath)
        let row = indexPath.row // Index
        // Put string name into cell
        cell.textLabel?.text = allergyList[row].description
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == recordCreationSegue,
           let creationVC = segue.destination as? MedicalRecordCreationVC {
            // Pass the current type
            creationVC.currentType = "Allergy"
            creationVC.docID = docID
            creationVC.delegate = self // pointer back to mainVC
        }
    }
    
    func addRecord(newRecord: MedicalInfo.Record) {
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("error: allergy user not auth")
            return
        }
        
        allergyList.append(newRecord)
        medicalInfo.addRecord(category: "Allergy", record: newRecord)
        
        Task {
            do {
                try await userManager.updateMedicalRecord(for: userId, records: self.allergyList, docID: docID, petID: pet.petID, type: "Allergy")
            } catch {
                throw error
            }
        }
        tableView.reloadData()
    }
        
}
