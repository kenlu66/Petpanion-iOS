//
//  ProfileCreationViewController.swift
//  Petpanion
//
//  Created by Xin Gao on 10/18/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Photos

class ProfileCreationViewController: UIViewController,UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petName: UITextField!
    @IBOutlet weak var breedName: UITextField!
    @IBOutlet weak var birthdate: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var petDescription: UITextField!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var submissionStatus: UILabel!
    @IBOutlet weak var sterilizationSelection: UIButton!
    @IBOutlet weak var genderSelection: UIButton!
    
    @IBOutlet weak var mealsPerDay: UITextField!
    @IBOutlet weak var amountPerMeal: UITextField!
    @IBOutlet weak var waterInput: UITextField!
    @IBOutlet weak var playtimeInput: UITextField!
    
    var datePicker: UIDatePicker!
    var delegate: UIViewController!
    let userManager = UserManager()
    var imagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        petName.delegate = self
        breedName.delegate = self
        birthdate.delegate = self
        weight.delegate = self
        petDescription.delegate = self
        mealsPerDay.delegate = self
        amountPerMeal.delegate = self
        waterInput.delegate = self
        playtimeInput.delegate = self
        
        
        
        
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
    
    @IBAction func addPhotoPressed(_ sender: Any) {
        checkPermissions()
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        
        // TODO: user imagePickerController for camera when we can test it
        // TODO: need to be able to switch the sourceType
        // imagePickerController.sourceType = .camera
        // present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // TODO: when picker is camera
        if picker.sourceType == .photoLibrary {
            petImage?.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func checkPermissions() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in () })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("Access for photo library granted")
        } else {
            print("Access for photo library not granted")
        }
    }
    
    @IBAction func sterilizationStatusPressed(_ sender: UIAction) {
        sterilizationSelection.setTitle(sender.title, for: .normal)
    }
    
    @IBAction func genderSelectionPressed(_ sender: UIAction) {
        genderSelection.setTitle(sender.title, for: .normal)
    }
    
    @IBAction func submitted(_ sender: Any) {
        
        guard let petNameText = petName.text, !petNameText.isEmpty,
              let breedNameText = breedName.text, !breedNameText.isEmpty,
              let neuteredText = sterilizationSelection.titleLabel?.text,
              let weightText = weight.text, let weightValue = Float(weightText),
              let genderText = genderSelection.titleLabel?.text,
              let petDescriptionText = petDescription.text,
              let meals = mealsPerDay.text, let mealNum = Float(meals),
              let amount = amountPerMeal.text, let amountNum = Float(amount),
              let water = waterInput.text, let waterNum = Float(water),
              let playtime = playtimeInput.text, let playtimeNum = Float(playtime)
        else {
            // Handle empty fields or invalid input here
            submissionStatus.text = ("Please fill in all fields correctly.")
            return
        }
        
        let imageData = convertImage(image: petImage.image ?? UIImage())
        let age = ageCalculation(birthDate: datePicker.date)
        let newPet = Pet(
           petName: petNameText,
           breedName: breedNameText,
           neutered: neuteredText,
           age: age,
           weight: weightValue,
           gender: genderText,
           petDescription: petDescriptionText,
           imageData: imageData ?? "",
           mealsPerDay: mealNum,
           amountPerMeal: amountNum,
           waterNeeded: waterNum,
           playtimeNeeded: playtimeNum,
           petID: ""
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
    
    func convertImage(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return nil}
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }
    
 
}
