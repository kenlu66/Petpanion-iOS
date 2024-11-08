////
////  AddReminderViewController.swift
////  Petpanion
////
////  Created by Kan Lu on 11/7/24.
////
//
//import UIKit
//import FirebaseAuth
//
//class AddReminderViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
//
//    @IBOutlet weak var titleTextField: UITextField!
//    @IBOutlet weak var datePicker: UIDatePicker!
//    @IBOutlet weak var petPicker: UIPickerView!
//
//    var pets = [Pet]() // List of pets for the user
//    var selectedPetName: String? // Name of the selected pet
//    var userId: String = Auth.auth().currentUser?.uid ?? ""
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        petPicker.delegate = self
//        petPicker.dataSource = self
//        fetchPets() // Load the pets from Firebase or another data source
//    }
//
//    // Fetch the user's pets to populate the picker
//    func fetchPets() {
//        Task {
//            do {
//                pets = try await UserManager().fetchPets(for: userId)
//                petPicker.reloadAllComponents()
//            } catch {
//                print("Error fetching pets: \(error)")
//            }
//        }
//    }
//
//    // MARK: - UIPickerView DataSource and Delegate
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return pets.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return pets[row].petName // Display pet names in picker
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        selectedPetName = pets[row].petName // Set selected pet name when a row is selected
//    }
//
//    // Save reminder with the selected pet
//    @IBAction func saveButtonTapped(_ sender: Any) {
//        guard let title = titleTextField.text, !title.isEmpty else {
//            print("Please enter a title.")
//            return
//        }
//
//        guard let petName = selectedPetName else {
//            print("Please select a pet.")
//            return
//        }
//
//        let time = datePicker.date
//        let reminder = Reminder(id: UUID().uuidString, title: title, time: time, isCompleted: false, petName: petName)
//
//        Task {
//            do {
//                try await UserManager().addReminder(for: userId, petName: petName, reminder: reminder)
//                NotificationScheduler.shared.scheduleNotification(for: reminder)
//                self.dismiss(animated: true, completion: nil)
//            } catch {
//                print("Error adding reminder: \(error)")
//            }
//        }
//    }
//}
//
//
