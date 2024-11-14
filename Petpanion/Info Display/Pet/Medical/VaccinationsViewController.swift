//
//  VaccinationsViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit

protocol addVaccine {
    func addRecord(newRecord: MedicalInfo.Record)
}

class VaccinationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addVaccine {
    
    var vaccineList: [MedicalInfo.Record] = []

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
        cell.textLabel?.text = vaccineList[row].description
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == recordCreationSegue,
           let creationVC = segue.destination as? MedicalRecordCreationVC {
            // Pass the current type
            creationVC.currentType = "Vaccine"
            creationVC.delegate = self // pointer back to mainVC
        }
    }
    
    func addRecord(newRecord: MedicalInfo.Record) {
        vaccineList.append(newRecord)
        tableView.reloadData()
    }
}
