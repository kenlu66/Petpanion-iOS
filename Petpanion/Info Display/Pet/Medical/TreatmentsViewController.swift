//
//  TreatmentsViewController.swift
//  Petpanion
//
//  Created by Ruolin Dong on 10/18/24.
//

import UIKit

protocol addTreatment {
    func addRecord(newRecord: MedicalInfo.Record)
}

class TreatmentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addTreatment {
    
    var treatmentList: [MedicalInfo.Record] = []
    var docID = ""
    var medicalInfo = MedicalInfo()
    var delegate: UIViewController!

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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TreatmentCell", for: indexPath)
        let row = indexPath.row // Index
        // Put string name into cell
        cell.textLabel?.text = treatmentList[row].description
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == recordCreationSegue,
           let creationVC = segue.destination as? MedicalRecordCreationVC {
            // Pass the current type
            creationVC.currentType = "Treatment"
            creationVC.docID = docID
            creationVC.delegate = self // pointer back to mainVC
        }
    }
    
    func addRecord(newRecord: MedicalInfo.Record) {
        treatmentList.append(newRecord)
        medicalInfo.addRecord(category: "Treatment", record: newRecord)
        tableView.reloadData()
    }

}
