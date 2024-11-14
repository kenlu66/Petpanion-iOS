//
//  AllergiesViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit

protocol addRecord {
    func addRecord(newRecord: MedicalInfo.Record)
}
class AllergiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addRecord {
    
    var allergyList: [MedicalInfo.Record] = []
    var medicalInfo = MedicalInfo()

    @IBOutlet weak var tableView: UITableView!
    let recordCreationSegue = "AllergyToCreation"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        allergyList = medicalInfo.getRecords(byCategory: "Allergy")
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
            creationVC.delegate = self // pointer back to mainVC
        }
    }
    
    func addRecord(newRecord: MedicalInfo.Record) {
        allergyList.append(newRecord)
        medicalInfo.addRecord(category: "Allergy", record: newRecord)
        tableView.reloadData()
    }
        
}
