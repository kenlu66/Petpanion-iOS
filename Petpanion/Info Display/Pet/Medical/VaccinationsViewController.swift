//
//  VaccinationsViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit
import FirebaseAuth

protocol addVaccine {
    func addRecord(newRecord: MedicalInfo.Record)
}

class VaccinationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addVaccine {
    
    let medicalInfo = MedicalInfo()
    let userManager = UserManager()
    var vaccineList: [MedicalInfo.Record] = []
    var docID = ""
    var delegate: UIViewController!
    var pet: Pet!

    @IBOutlet weak var tableView: UITableView!
    let recordCreationSegue = "VaccineToCreation"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaccineList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath)
        let row = indexPath.row // Index
        // Put string name into cell
        let record = """
        \(vaccineList[row].date)
            \(vaccineList[row].description)
            \(vaccineList[row].location)
        """
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = record
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == recordCreationSegue,
           let creationVC = segue.destination as? MedicalRecordCreationVC {
            // Pass the current type
            creationVC.currentType = "Vaccine"
            creationVC.docID = docID
            creationVC.delegate = self // pointer back to mainVC
        }
    }
    
    func addRecord(newRecord: MedicalInfo.Record) {
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("error: vaccine user not auth")
            return
        }
        
        vaccineList.append(newRecord)
        medicalInfo.addRecord(category: "Vaccine", record: newRecord)
        
        Task {
            do {
                try await userManager.updateMedicalRecord(for: userId, records: self.vaccineList, docID: docID, petID: pet.petID, type: "Vaccine")
            } catch {
                throw error
            }
        }
        
        tableView.reloadData()
    }
}
