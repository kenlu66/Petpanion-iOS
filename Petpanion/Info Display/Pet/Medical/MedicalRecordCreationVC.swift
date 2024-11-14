//
//  MedicalRecordCreationVC.swift
//  Petpanion
//
//  Created by Mengying Jin on 11/13/24.
//

import UIKit

class MedicalRecordCreationVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var currentType: String!
    var delegate: UIViewController!
    var medicalInfo = MedicalInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateField.delegate = self
        descriptionField.delegate = self
        locationField.delegate = self
        

    }
    
    // MARK: - Keyboard Dismiss
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
 
    @IBAction func submitPressed(_ sender: Any) {
        guard let date = dateField.text,
              let description = descriptionField.text,
              let location = locationField.text else { return }
        
        // Create a new record based on the currentType
        var newRecord: MedicalInfo.Record
        
        switch currentType {
        case "Allergy":
            newRecord = MedicalInfo.Record(description: description, date: date, location: location, category: "Allergy")
            let allergyVC = delegate as! addRecord
            allergyVC.addRecord(newRecord: newRecord)
            
        case "Vaccine":
            newRecord = MedicalInfo.Record(description: description, date: date, location: location, category: "Vaccine")
            let vaccineVC = delegate as! addVaccine
            vaccineVC.addRecord(newRecord: newRecord)
        case "Treatment":
            newRecord = MedicalInfo.Record(description: description, date: date, location: location, category: "Treatment")
            let treatmentVC = delegate as! addTreatment
            treatmentVC.addRecord(newRecord: newRecord)
        default:
            print("Invalid record type")
            return
        }
        
    }
}
