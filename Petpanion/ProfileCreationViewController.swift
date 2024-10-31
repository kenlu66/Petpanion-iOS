//
//  ProfileCreationViewController.swift
//  Petpanion
//
//  Created by Xin Gao on 10/18/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfileCreationViewController: UIViewController {

    
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petName: UITextField!
    @IBOutlet weak var breedName: UITextField!
    @IBOutlet weak var neutered: UITextField!
    @IBOutlet weak var birthdate: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var petDescription: UITextField!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var submissionStatus: UILabel!
    
    var datePicker: UIDatePicker!
    var delegate: UIViewController!
    let userManager = UserManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        petImage.layer.cornerRadius = petImage.frame.height / 2
        petImage.layer.masksToBounds = true
        submissionStatus.text = ""
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        
        birthdate.inputView = datePicker
        birthdate.text = ""
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        birthdate.text = dateFormat(date: datePicker.date)
    }
    
    func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    func ageCalculation(birthDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: birthDate, to: Date())
        return components.year ?? 0
    }
    
    @IBAction func submitted(_ sender: Any) {
        guard let petNameText = petName.text, !petNameText.isEmpty,
                     let breedNameText = breedName.text, !breedNameText.isEmpty,
                     let neuteredText = neutered.text,
                     let weightText = weight.text, let weightValue = Float(weightText),
                     let genderText = gender.text,
                     let petDescriptionText = petDescription.text else {
                   // Handle empty fields or invalid input here
                   print("Please fill in all fields correctly.")
                   return
               }

       let age = ageCalculation(birthDate: datePicker.date)
       let newPet = Pet(
           petName: petNameText,
           breedName: breedNameText,
           neutered: neuteredText,
           age: age,
           weight: weightValue,
           gender: genderText,
           petDescription: petDescriptionText
       )
        
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            submissionStatus.text = "User not authenticated."
            return
        }

        // Add the pet to Firestore
        Task {
            do {
                try await userManager.addPet(for: userId, pet: newPet)
                submissionStatus.text = "Pet profile submitted successfully!"
                
                // Notify delegate if needed
                if let mainVC = delegate as? updatePetList {
                    mainVC.updatePet(pet: newPet)
                }
            } catch {
                submissionStatus.text = "Error adding pet: \(error.localizedDescription)"
            }
        }
    }
}
