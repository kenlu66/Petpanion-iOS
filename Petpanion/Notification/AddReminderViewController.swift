//
//  AddReminderViewController.swift
//  Petpanion
//
//  Created by Kan Lu on 11/7/24.
//

import UIKit
import FirebaseAuth

class AddReminderViewController: UIViewController {
    
    @IBOutlet var titleField:UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    public var completion: ((String, String, Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapSaveButton() {
        if let titleText = titleField.text, !titleText.isEmpty,
        let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = datePicker.date
        }
    }
    
}
