//
//  AddReminderViewController.swift
//  Petpanion
//
//  Created by Kan Lu on 11/7/24.
//

import UIKit
import FirebaseAuth

class AddReminderViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var titleField:UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    
    public var completion: ((String, String, Date, String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.delegate = self
        bodyField.delegate = self
        tagField.delegate = self
        locationField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSaveButton))
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titleField.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty,
           let tagText = tagField.text, !tagText.isEmpty,
           let locationText = locationField.text, !locationText.isEmpty
        {
            let targetDate = datePicker.date
            
            
            completion?(titleText, bodyText, targetDate, tagText, locationText)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
