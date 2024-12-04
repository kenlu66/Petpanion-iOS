//
//  ProfileCreationViewController.swift
//  Petpanion
//
//  Created by Xin Gao on 10/18/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
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
    let storageManager = StorageManager()
    var imagePickerController = UIImagePickerController()
    
    var status: String!
    var selectedPet: Pet!
    var petList: [Pet]!
    var imageList: [UIImage]!
    var image: UIImage!
    var petIndex: Int!
    var imageChanged = 0

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
        
        if (status == "update") {
            fillInFields()
            print("updated fields")
        }
    }
    
    func fillInFields() {
        if let pet = selectedPet {
                // Populate the fields with the pet's existing data
                petName.text = pet.petName
                breedName.text = pet.breedName
                birthdate.text = dateFormat(date: pet.birthdate)
                weight.text = String(pet.weight)
                petDescription.text = pet.petDescription
                sterilizationSelection.setTitle(pet.neutered, for: .normal)
                genderSelection.setTitle(pet.gender, for: .normal)
                mealsPerDay.text = String(pet.mealsPerDay)
                amountPerMeal.text = String(pet.amountPerMeal)
                waterInput.text = String(pet.waterNeeded)
                playtimeInput.text = String(pet.playtimeNeeded)
                
                petImage.image = image
                
            }
        datePicker.date = selectedPet.birthdate
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
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // You can allow the user to switch between library and camera
            let alertController = UIAlertController(title: "Choose Source", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        } else {
            // No camera available, fall back to photo library
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker.sourceType == .photoLibrary || picker.sourceType == .camera {
            petImage.contentMode = .scaleAspectFit
            petImage?.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            
            picker.dismiss(animated: true, completion: nil)
            print("image changed")
            imageChanged = 1
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
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {
                (accessGranted) in
                guard accessGranted == true else { return }
            }
        case .authorized:
            break
        default:
            print("Access denied")
            return
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
        
        var path = ""
        var petID = UUID().uuidString
        
        if (status == "update") {
            print("in update")
            petID = selectedPet.petID
            print(petID)
            if (imageChanged == 1) {
                storageManager.deleteImage(filePath: selectedPet.imageData)
                if let image = petImage.image {
                    let photoID = UUID().uuidString
                    path = "PetProfileImages/\(photoID).jpeg"
                    storageManager.storeImage(filePath: path, image: image)
                }
            } else {
                path = selectedPet.imageData
            }
        } else if (status == "creation") {
            if let image = petImage.image {
                let photoID = UUID().uuidString
                path = "PetProfileImages/\(photoID).jpeg"
                storageManager.storeImage(filePath: path, image: image)
            }
        }
        
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
        
        let imageData = path
        let age = ageCalculation(birthDate: datePicker.date)
        let newPet = Pet(
           petName: petNameText,
           breedName: breedNameText,
           neutered: neuteredText,
           age: age,
           weight: weightValue,
           gender: genderText,
           petDescription: petDescriptionText,
           imageData: imageData,
           mealsPerDay: mealNum,
           amountPerMeal: amountNum,
           waterNeeded: waterNum,
           playtimeNeeded: playtimeNum,
           petID: petID,
           bDay: datePicker.date
        )
        
        // Ensure the user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            submissionStatus.text = "User not authenticated."
            return
        }

        // Add the pet to Firestore
        Task {	
            do {
                
                if status == "update" {
                    print(newPet.petID)
                    print("a spacer i status")
                    // Update the existing pet if editing
                    try await userManager.updatePet(for: userId, pet: newPet)
                    
                    if let infoVC = delegate as? updatePet {
                        print("right before update pet func")
                        print(newPet.petID)
                        self.petList[self.petIndex] = newPet
                        self.imageList[self.petIndex] = self.image
                        infoVC.updatePet(pet: newPet, petInd: petIndex, pList: petList, iList: imageList)
                    }

                    submissionStatus.text = "Pet profile updated successfully!"
                } else {
                    // Add new pet if this is the first time
                    try await userManager.addPet(for: userId, pet: newPet)
                    
                    if let mainVC = delegate as? changePetList {
                        mainVC.addPet(pet: newPet)
                    }

                    submissionStatus.text = "Pet profile submitted successfully!"
                }
    
            } catch {
                submissionStatus.text = "Error adding pet: \(error.localizedDescription)"
            }
        }
    }
    
}
